-- ============================================================================
-- GatherResource Component Support - Migration Script
-- ============================================================================
-- This script creates:
-- 1. items.item_images table for resource images
-- 2. players.player_inventory table to track gathered resources per player
-- 3. world.get_map_tile_resource_detail function (fog-of-war aware)
-- 4. items.do_gather_resources_on_map_tile_action function (async action)
-- ============================================================================

BEGIN;

-------------------------------------------------------------------------------
-- TABLE: items.item_images
-- Purpose: Store images for resources/items
-------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS items.item_images (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES items.items(id) ON DELETE CASCADE,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(item_id)
);

-- Index for faster lookups by item_id
CREATE INDEX IF NOT EXISTS idx_item_images_item_id ON items.item_images(item_id);


-------------------------------------------------------------------------------
-- TABLE: players.player_inventory
-- Purpose: Track gathered resources per player (simplified tracking)
-- Note: This is a simplified view/table that aggregates inventory_slots data
-------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS players.player_inventory (
    id SERIAL PRIMARY KEY,
    player_id INTEGER NOT NULL REFERENCES players.players(id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES items.items(id) ON DELETE CASCADE,
    quantity INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(player_id, item_id)
);

-- Indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_player_inventory_player_id ON players.player_inventory(player_id);
CREATE INDEX IF NOT EXISTS idx_player_inventory_item_id ON players.player_inventory(item_id);


-------------------------------------------------------------------------------
-- FUNCTION: world.get_map_tile_resource_detail
-- Purpose: Returns resource name, quantity, and image for display (fog-of-war aware)
-- API Type: get_api
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION world.get_map_tile_resource_detail(
    p_map_id INTEGER,
    p_map_tile_x INTEGER,
    p_map_tile_y INTEGER,
    p_player_id INTEGER
)
RETURNS TABLE (
    resource_name VARCHAR,
    quantity INTEGER,
    image_url VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN

RETURN QUERY
SELECT 
    i.name AS resource_name,
    mtr.quantity,
    COALESCE(
        ii.image_url,
        i.image,
        'default.png'
    ) AS image_url
FROM world.map_tiles_resources mtr
JOIN items.items i ON mtr.item_id = i.id
LEFT JOIN items.item_images ii ON mtr.item_id = ii.item_id
WHERE mtr.map_id = p_map_id
  AND mtr.map_tile_x = p_map_tile_x
  AND mtr.map_tile_y = p_map_tile_y
  -- Fog-of-war: Only return resources the player knows about
  AND EXISTS (
      SELECT 1 
      FROM knowledge.known_map_tiles_resources kmtr
      WHERE kmtr.player_id = p_player_id
        AND kmtr.map_tiles_resource_id = mtr.id
  );

END;
$function$;


-------------------------------------------------------------------------------
-- FUNCTION: items.do_gather_resources_on_map_tile_action
-- Purpose: Action to gather resources and add to inventory (async)
-- API Type: action_api
-- Returns: TABLE(status boolean, message text)
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION items.do_gather_resources_on_map_tile_action(
    p_player_id INTEGER,
    parameters JSONB
)
RETURNS TABLE(status BOOLEAN, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    param JSONB;
    base_time TIMESTAMP;
    scheduled_time TIMESTAMP;
    resource_count INTEGER;
BEGIN

-- MUTEX: Lock player row to prevent concurrent operations
PERFORM 1
FROM players.players
WHERE id = p_player_id
FOR UPDATE;

-- Cancel any existing gather task for this player
PERFORM tasks.cancel_task(p_player_id, 'items.gather_resources_on_map_tile_action');

-- Get the base time from existing tasks or current time
SELECT COALESCE(MAX(t1.scheduled_at), NOW())
INTO base_time
FROM tasks.tasks t1
WHERE t1.player_id = p_player_id
  AND t1.status IN (1, 2);

-- Count total resources to gather
SELECT COUNT(*) INTO resource_count
FROM world.map_tiles_resources mtr
JOIN items.items i ON mtr.item_id = i.id
WHERE mtr.map_id = (
    SELECT map_id FROM world.map_tiles_players_positions 
    WHERE player_id = p_player_id AND map_tile_x = (
        SELECT map_tile_x FROM knowledge.known_map_tiles 
        WHERE player_id = p_player_id AND map_id = ANY(ARRAY(SELECT DISTINCT map_id FROM knowledge.known_map_tiles WHERE player_id = p_player_id))
        LIMIT 1
    )
);

-- Process each gather request in the parameters array
FOR param IN 
    SELECT * FROM jsonb_array_elements(parameters)
LOOP
    
    -- Extract gather amount from parameter (default to 1 if not specified)
    DECLARE
        v_gather_amount INTEGER := 1;
        v_map_id INTEGER;
        v_map_tile_x INTEGER;
        v_map_tile_y INTEGER;
        v_item_id INTEGER;
        v_quantity INTEGER;
    BEGIN
        
        -- Get gather amount from parameter or use default
        v_gather_amount := COALESCE((param->>'gatherAmount')::INTEGER, 1);
        
        -- Validate gather amount
        PERFORM util.raise_error('Gather amount must be a positive integer')
        WHERE v_gather_amount <= 0;
        
        -- Get player's current position to determine which tile to gather from
        SELECT map_id, map_tile_x, map_tile_y INTO v_map_id, v_map_tile_x, v_map_tile_y
        FROM world.map_tiles_players_positions 
        WHERE player_id = p_player_id
        LIMIT 1;
        
        -- Get resource details for the current tile
        SELECT mtr.item_id, mtr.quantity INTO v_item_id, v_quantity
        FROM world.map_tiles_resources mtr
        WHERE mtr.map_id = v_map_id
          AND mtr.map_tile_x = v_map_tile_x
          AND mtr.map_tile_y = v_map_tile_y;
        
        -- Check if resource exists and has quantity
        IF v_item_id IS NULL OR v_quantity <= 0 THEN
            RAISE NOTICE 'No resources available to gather at current position';
            CONTINUE;
        END IF;
        
        -- Calculate scheduled time (1 minute per unit gathered)
        scheduled_time := base_time + ((v_gather_amount)::INTEGER * INTERVAL '1 minute');
        
        -- Insert task for async execution
        PERFORM tasks.insert_task(
            p_player_id,
            scheduled_time,
            'items.execute_gather_resources',
            param::JSONB
        );
        
    END;

END LOOP;

-- Return success message
RETURN QUERY SELECT TRUE, 'Gather resources action assigned successfully';

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM;
END;
$function$;


-------------------------------------------------------------------------------
-- FUNCTION: items.execute_gather_resources
-- Purpose: Execute the actual gathering and inventory update (async worker)
-- API Type: action_api (internal)
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION items.execute_gather_resources(
    p_player_id INTEGER,
    parameters JSONB
)
RETURNS TABLE(status BOOLEAN, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_map_id INTEGER;
    v_map_tile_x INTEGER;
    v_map_tile_y INTEGER;
    v_item_id INTEGER;
    v_quantity INTEGER;
    v_gather_amount INTEGER;
    v_new_quantity INTEGER;
BEGIN

-- Get player's current position
SELECT map_id, map_tile_x, map_tile_y INTO v_map_id, v_map_tile_x, v_map_tile_y
FROM world.map_tiles_players_positions 
WHERE player_id = p_player_id
LIMIT 1;

IF v_map_id IS NULL THEN
    RETURN QUERY SELECT FALSE, 'Player not found on any map';
END IF;

-- Get gather amount from parameters
v_gather_amount := COALESCE((parameters->>'gatherAmount')::INTEGER, 1);

-- Get resource details for the current tile
SELECT mtr.item_id, mtr.quantity INTO v_item_id, v_quantity
FROM world.map_tiles_resources mtr
WHERE mtr.map_id = v_map_id
  AND mtr.map_tile_x = v_map_tile_x
  AND mtr.map_tile_y = v_map_tile_y;

-- Check if resource exists and has sufficient quantity
IF v_item_id IS NULL THEN
    RETURN QUERY SELECT FALSE, 'No resources available to gather at current position';
END IF;

IF v_quantity <= 0 THEN
    RETURN QUERY SELECT FALSE, 'Resource quantity is zero or depleted';
END IF;

-- Calculate new quantity after gathering
v_new_quantity := GREATEST(1, v_quantity - v_gather_amount);

-- Update the resource quantity in map_tiles_resources
UPDATE world.map_tiles_resources
SET quantity = v_new_quantity
WHERE id IN (
    SELECT mtr.id 
    FROM world.map_tiles_resources mtr
    WHERE mtr.map_id = v_map_id
      AND mtr.map_tile_x = v_map_tile_x
      AND mtr.map_tile_y = v_map_tile_y
);

-- Add gathered item to player's inventory
PERFORM inventory.do_add_item_to_inventory(
    (SELECT id FROM inventory.inventory_containers WHERE owner_id = p_player_id LIMIT 1),
    v_item_id,
    v_gather_amount
);

-- Update player_inventory tracking table
INSERT INTO players.player_inventory (player_id, item_id, quantity)
VALUES (p_player_id, v_item_id, v_gather_amount)
ON CONFLICT (player_id, item_id) 
DO UPDATE SET quantity = players.player_inventory.quantity + v_gather_amount,
               updated_at = NOW();

-- Return success
RETURN QUERY SELECT TRUE, 'Successfully gathered resources';

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM;
END;
$function$;


-------------------------------------------------------------------------------
-- INDEX: Ensure FK columns have matching indexes
-------------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_item_images_item_id ON items.item_images(item_id);
CREATE INDEX IF NOT EXISTS idx_player_inventory_player_id ON players.player_inventory(player_id);
CREATE INDEX IF NOT EXISTS idx_player_inventory_item_id ON players.player_inventory(item_id);

COMMIT;
