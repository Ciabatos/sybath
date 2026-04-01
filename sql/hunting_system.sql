-- ============================================================================
-- HUNTING SYSTEM - Complete Implementation
-- ============================================================================

-- Step 1: Create hunting item types
INSERT INTO items.item_types (id, name) VALUES
(2, 'Animal'),           -- For wild animals that can be hunted
(3, 'Meat')             -- For meat obtained from hunting
ON CONFLICT DO NOTHING;

-- Step 2: Add animal items (hunting targets)
INSERT INTO items.items (id, name, description, image, item_type_id) VALUES
(101, 'Wolf', 'A fierce predator of the forest', 'wolf.png', 2),
(102, 'Bear', 'A massive creature dwelling in deep woods', 'bear.png', 2),
(103, 'Boar', 'An aggressive wild pig with sharp tusks', 'boar.png', 2),
(104, 'Deer', 'A graceful herbivore found in forests', 'deer.png', 2),
(105, 'Rabbit', 'A small creature that scurries through bushes', 'rabbit.png', 2)
ON CONFLICT DO NOTHING;

-- Step 3: Add meat items (hunting rewards)
INSERT INTO items.items (id, name, description, image, item_type_id) VALUES
(106, 'Wolf Meat', 'Raw meat from a hunted wolf', 'wolf_meat.png', 3),
(107, 'Bear Meat', 'Heavy meat from a hunted bear', 'bear_meat.png', 3),
(108, 'Boar Meat', 'Tough meat from a hunted boar', 'boar_meat.png', 3),
(109, 'Deer Meat', 'Lean and tender meat from a deer', 'deer_meat.png', 3),
(110, 'Rabbit Meat', 'Small but nutritious rabbit meat', 'rabbit_meat.png', 3)
ON CONFLICT DO NOTHING;

-- Step 4: Add stats for meat items (nutrition value)
INSERT INTO attributes.stats (id, name, description, image) VALUES
(5, 'Nutrition', 'Provides food and sustenance to the player', 'nutrition.png')
ON CONFLICT DO NOTHING;

INSERT INTO items.item_stats (item_id, stat_id, value) VALUES
(106, 5, 25),   -- Wolf meat nutrition
(107, 5, 40),   -- Bear meat nutrition
(108, 5, 30),   -- Boar meat nutrition
(109, 5, 20),   -- Deer meat nutrition
(110, 5, 10)    -- Rabbit meat nutrition
ON CONFLICT DO NOTHING;

-- Step 5: Create hunting action API function
CREATE OR REPLACE FUNCTION world.do_hunt_on_map_tile(
    p_player_id integer,
    p_map_id integer,
    p_x integer,
    p_y integer,
    p_animal_type character varying DEFAULT 'any'
)
RETURNS TABLE(status boolean, message text)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tile_x integer;
    v_tile_y integer;
    v_map_id_found integer;
    v_resource_count integer := 0;
    v_hunt_success boolean := false;
    v_animal_item_id integer;
    v_meat_item_id integer;
    v_message text;
    v_error_msg text;
BEGIN

    -- Validate player exists and is active
    PERFORM 1 FROM players.players WHERE id = p_player_id AND is_active = true
    FOR UPDATE;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Player not found or inactive';
    END IF;

    -- Get current player position
    GET CURRENT TRANSACTION;
    
    -- Check if player is at the specified location
    PERFORM v_tile_x, v_tile_y FROM world.map_tiles_players_positions 
    WHERE player_id = p_player_id AND map_id = p_map_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Player is not on this map';
    END IF;

    -- Check if tile exists and is known to player
    PERFORM 1 FROM world.map_tiles mt 
    WHERE mt.map_id = p_map_id AND mt.x = p_x AND mt.y = p_y
    FOR UPDATE;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Tile does not exist on this map';
    END IF;

    -- Check if tile is known to player (fog of war)
    PERFORM 1 FROM knowledge.known_map_tiles kmt 
    WHERE kmt.player_id = p_player_id AND kmt.map_id = p_map_id 
          AND kmt.map_tile_x = p_x AND kmt.map_tile_y = p_y;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'This tile is not yet explored';
    END IF;

    -- Check if there are animals on this tile (resources)
    v_resource_count := COALESCE((SELECT COUNT(*) FROM world.map_tiles_resources 
                                  WHERE map_id = p_map_id AND map_tile_x = p_x AND map_tile_y = p_y), 0);
    
    IF v_resource_count = 0 THEN
        RETURN QUERY SELECT false, 'No animals found on this tile';
    END IF;

    -- Determine which animal to hunt based on type parameter
    CASE 
        WHEN p_animal_type = 'any' OR p_animal_type = '' THEN
            -- Random animal from available resources
            SELECT w.mtr.id INTO v_animal_item_id
            FROM world.map_tiles_resources w
            WHERE w.map_id = p_map_id AND w.map_tile_x = p_x AND w.map_tile_y = p_y
            ORDER BY RANDOM() LIMIT 1;
            
        WHEN p_animal_type IN ('wolf', 'bear', 'boar', 'deer', 'rabbit') THEN
            -- Try to find specific animal type
            SELECT w.mtr.id INTO v_animal_item_id
            FROM world.map_tiles_resources w
            JOIN items i ON w.item_id = i.id
            WHERE w.map_id = p_map_id AND w.map_tile_x = p_x AND w.map_tile_y = p_y
              AND LOWER(i.name) LIKE '%' || p_animal_type || '%'
            ORDER BY RANDOM() LIMIT 1;
            
        ELSE
            RETURN QUERY SELECT false, 'Invalid animal type specified';
    END CASE;

    -- Check if we found a valid animal to hunt
    IF v_animal_item_id IS NULL THEN
        RETURN QUERY SELECT false, 'No suitable animals available on this tile';
    END IF;

    -- Get the meat item that will be obtained from hunting this animal
    SELECT i2.id INTO v_meat_item_id
    FROM items i1
    JOIN items i2 ON i1.item_type_id = i2.item_type_id AND i2.name LIKE '%Meat'
    WHERE i1.id = v_animal_item_id;

    IF v_meat_item_id IS NULL THEN
        RETURN QUERY SELECT false, 'Cannot determine meat type for this animal';
    END IF;

    -- Check player inventory capacity before adding loot
    PERFORM 1 FROM inventory.inventory_containers ic
    JOIN inventory.inventory_slots islot ON ic.id = islot.inventory_container_id
    WHERE ic.owner_id = p_player_id AND islot.item_id IS NULL
    LIMIT 1;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Inventory is full. Cannot collect hunting loot';
    END IF;

    -- Remove animal from map tile (it's been hunted)
    UPDATE world.map_tiles_resources 
    SET quantity = quantity - 1 
    WHERE map_id = p_map_id AND map_tile_x = p_x AND map_tile_y = p_y AND item_id = v_animal_item_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Could not remove animal from tile';
    END IF;

    -- Add meat to player inventory
    INSERT INTO inventory.inventory_slots (inventory_container_id, item_id, quantity)
    VALUES (1, v_meat_item_id, 1);
    
    RETURN QUERY SELECT true, 'Successfully hunted animal and collected meat';
    
EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_msg = MESSAGE_TEXT;
    RETURN QUERY SELECT false, COALESCE(v_error_msg, 'An error occurred during hunting: ' || SQLERRM);
END;
$$;

-- Step 6: Create helper function to get available animals on a tile (for UI)
CREATE OR REPLACE FUNCTION world.get_available_animals_on_tile(
    p_map_id integer,
    p_x integer,
    p_y integer,
    p_player_id text
)
RETURNS TABLE(animal_item_id integer, animal_name character varying, meat_item_id integer, meat_name character varying)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mtr.item_id as animal_item_id,
        i.name as animal_name,
        CASE WHEN mt2.id IS NOT NULL THEN mt2.id ELSE NULL END as meat_item_id,
        CASE WHEN mt2.name IS NOT NULL THEN mt2.name ELSE 'Unknown Meat' END as meat_name
    FROM world.map_tiles_resources mtr
    JOIN items i ON mtr.item_id = i.id
    LEFT JOIN items mt2 ON i.item_type_id = mt2.item_type_id AND mt2.name LIKE '%Meat%'
    WHERE mtr.map_id = p_map_id 
      AND mtr.map_tile_x = p_x 
      AND mtr.map_tile_y = p_y
      AND mtr.quantity > 0;
END;
$$;

-- Step 7: Create function to check if player can hunt on a tile (validation)
CREATE OR REPLACE FUNCTION world.can_hunt_on_tile(
    p_player_id integer,
    p_map_id integer,
    p_x integer,
    p_y integer
)
RETURNS TABLE(can_hunt boolean, reason text)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE 
            WHEN NOT EXISTS (SELECT 1 FROM players.players WHERE id = p_player_id AND is_active = true) THEN false
            ELSE true
        END as can_hunt,
        CASE 
            WHEN NOT EXISTS (SELECT 1 FROM world.map_tiles_players_positions WHERE player_id = p_player_id AND map_id = p_map_id) THEN 'Player not on this map'
            WHEN NOT EXISTS (SELECT 1 FROM world.map_tiles WHERE map_id = p_map_id AND x = p_x AND y = p_y) THEN 'Tile does not exist'
            WHEN NOT EXISTS (SELECT 1 FROM knowledge.known_map_tiles WHERE player_id = p_player_id AND map_id = p_map_id AND map_tile_x = p_x AND map_tile_y = p_y) THEN 'Tile not explored'
            WHEN COALESCE((SELECT COUNT(*) FROM world.map_tiles_resources WHERE map_id = p_map_id AND map_tile_x = p_x AND map_tile_y = p_y), 0) = 0 THEN 'No animals on tile'
            ELSE true
        END as reason;
END;
$$;

