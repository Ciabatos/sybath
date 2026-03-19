-- Migration: Crafting Tree System
-- Purpose: Add recipe catalog, material requirements, and crafting session tracking
-- Schema: items (primary), with FKs to attributes, buildings, players, inventory

BEGIN;

-- ============================================================
-- SECTION 1: New Reference Tables
-- ============================================================

-- Recipe categories (Weapons, Armor, Spells)
CREATE TABLE IF NOT EXISTS items.recipe_categories (
    id SERIAL PRIMARY KEY,
    name character varying(50) NOT NULL UNIQUE,
    icon_type_id INTEGER REFERENCES attributes.abilities(id),
    description character varying(255),
    sort_order INTEGER DEFAULT 1 NOT NULL
);

-- Insert seed data for three categories
INSERT INTO items.recipe_categories (name, icon_type_id, description, sort_order) VALUES
('Weapons', NULL, 'Craft weapons to enhance your combat abilities', 1),
('Armor', NULL, 'Craft armor to protect yourself in battle', 2),
('Spells', NULL, 'Craft magical spells and potions', 3);

-- ============================================================
-- SECTION 2: Core Recipe Catalog Table
-- ============================================================

CREATE TABLE IF NOT EXISTS items.recipes (
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES items.recipe_categories(id) ON DELETE RESTRICT,
    name character varying(100) NOT NULL,
    description character varying(500),
    tier INTEGER NOT NULL DEFAULT 1 CHECK (tier > 0 AND tier <= 10),
    crafting_time_minutes INTEGER NOT NULL DEFAULT 0,
    level_requirement INTEGER NOT NULL DEFAULT 1,
    skill_requirement_id INTEGER REFERENCES attributes.skills(id),
    ability_requirement_id INTEGER REFERENCES attributes.abilities(id),
    gold_cost INTEGER NOT NULL DEFAULT 0 CHECK (gold_cost >= 0),
    rarity_id INTEGER REFERENCES items.item_types(id),
    location_building_id INTEGER REFERENCES buildings.buildings(id),
    image_url character varying(255) DEFAULT 'default_recipe.png'
);

-- Unique constraint: no duplicate recipe names within a category
CREATE UNIQUE INDEX idx_recipes_category_name ON items.recipes (category_id, name);

-- Indexes for filtering and lookups
CREATE INDEX idx_recipes_category_id ON items.recipes (category_id);
CREATE INDEX idx_recipes_tier ON items.recipes (tier);
CREATE INDEX idx_recipes_level_requirement ON items.recipes (level_requirement);

-- ============================================================
-- SECTION 3: Recipe Materials Table
-- ============================================================

CREATE TABLE IF NOT EXISTS items.recipe_materials (
    id SERIAL PRIMARY KEY,
    recipe_id INTEGER NOT NULL REFERENCES items.recipes(id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES items.items(id),
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    sort_order INTEGER NOT NULL DEFAULT 0
);

-- Unique constraint: no duplicate materials for same recipe
CREATE UNIQUE INDEX idx_recipe_materials_recipe_item ON items.recipe_materials (recipe_id, item_id);

-- Indexes for lookups
CREATE INDEX idx_recipe_materials_recipe_id ON items.recipe_materials (recipe_id);
CREATE INDEX idx_recipe_materials_item_id ON items.recipe_materials (item_id);

-- ============================================================
-- SECTION 4: Recipe Stats Table
-- ============================================================

CREATE TABLE IF NOT EXISTS items.recipe_stats (
    id SERIAL PRIMARY KEY,
    recipe_id INTEGER NOT NULL REFERENCES items.recipes(id) ON DELETE CASCADE,
    stat_id INTEGER NOT NULL REFERENCES attributes.stats(id),
    value INTEGER NOT NULL DEFAULT 0 CHECK (value >= 0)
);

-- Unique constraint: no duplicate stats for same recipe
CREATE UNIQUE INDEX idx_recipe_stats_recipe_stat ON items.recipe_stats (recipe_id, stat_id);

-- Indexes for lookups
CREATE INDEX idx_recipe_stats_recipe_id ON items.recipe_stats (recipe_id);
CREATE INDEX idx_recipe_stats_stat_id ON items.recipe_stats (stat_id);

-- ============================================================
-- SECTION 5: Crafting Sessions Table
-- ============================================================

CREATE TABLE IF NOT EXISTS items.crafting_sessions (
    id SERIAL PRIMARY KEY,
    player_id INTEGER NOT NULL REFERENCES players.players(id) ON DELETE CASCADE,
    recipe_id INTEGER NOT NULL REFERENCES items.recipes(id),
    status character varying(20) NOT NULL DEFAULT 'in_progress' CHECK (status IN ('queued', 'in_progress', 'completed', 'failed', 'cancelled')),
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100)
);

-- Unique constraint: one active session per player per recipe
CREATE UNIQUE INDEX idx_crafting_sessions_player_recipe ON items.crafting_sessions (player_id, recipe_id);

-- Indexes for lookups
CREATE INDEX idx_crafting_sessions_player_id ON items.crafting_sessions (player_id);
CREATE INDEX idx_crafting_sessions_status ON items.crafting_sessions (status);


-- ============================================================
-- SECTION 6: automatic_get_api Functions (Reference Data)
-- ============================================================

COMMENT ON TABLE items.recipe_categories IS 'Recipe categories for tab navigation in crafting tree UI';
COMMENT ON TABLE items.recipes IS 'Core recipe catalog with costs, requirements, and properties';
COMMENT ON TABLE items.recipe_materials IS 'Material requirements per recipe (multiple materials supported)';
COMMENT ON TABLE items.recipe_stats IS 'Stats provided by crafted items (e.g., Heart:25, Shield:10)';
COMMENT ON TABLE items.crafting_sessions IS 'Tracks active crafting sessions for players';

-- Function pairs for categories
CREATE OR REPLACE FUNCTION items.get_recipe_categories()
RETURNS TABLE(
    id integer,
    name character varying,
    icon_type_id integer,
    description character varying,
    sort_order integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rc.id,
        rc.name,
        rc.icon_type_id,
        rc.description,
        rc.sort_order
    FROM items.recipe_categories rc
    ORDER BY rc.sort_order;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION items.get_recipe_categories() IS 'automatic_get_api: Returns all recipe categories for tab navigation';

CREATE OR REPLACE FUNCTION items.get_recipe_category_by_key(p_id integer)
RETURNS TABLE(
    id integer,
    name character varying,
    icon_type_id integer,
    description character varying,
    sort_order integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rc.id,
        rc.name,
        rc.icon_type_id,
        rc.description,
        rc.sort_order
    FROM items.recipe_categories rc
    WHERE rc.id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION items.get_recipe_category_by_key(p_id integer) IS 'automatic_get_api: Get a single recipe category by ID';

-- Function pairs for recipes
CREATE OR REPLACE FUNCTION items.get_recipes()
RETURNS TABLE(
    id integer,
    category_id integer,
    name character varying,
    description character varying,
    tier integer,
    crafting_time_minutes integer,
    level_requirement integer,
    rarity_id integer,
    image_url character varying
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.category_id,
        r.name,
        r.description,
        r.tier,
        r.crafting_time_minutes,
        r.level_requirement,
        r.rarity_id,
        r.image_url
    FROM items.recipes r
    ORDER BY r.category_id, r.name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION items.get_recipes() IS 'automatic_get_api: Returns all recipes in the catalog';

CREATE OR REPLACE FUNCTION items.get_recipes_by_key(p_id integer)
RETURNS TABLE(
    id integer,
    category_id integer,
    name character varying,
    description character varying,
    tier integer,
    crafting_time_minutes integer,
    level_requirement integer,
    rarity_id integer,
    image_url character varying
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.category_id,
        r.name,
        r.description,
        r.tier,
        r.crafting_time_minutes,
        r.level_requirement,
        r.rarity_id,
        r.image_url
    FROM items.recipes r
    WHERE r.id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION items.get_recipes_by_key(p_id integer) IS 'automatic_get_api: Get a single recipe by ID';

-- Function pairs for materials
CREATE OR REPLACE FUNCTION items.get_recipe_materials()
RETURNS TABLE(
    id integer,
    recipe_id integer,
    item_id integer,
    quantity integer,
    sort_order integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rm.id,
        rm.recipe_id,
        rm.item_id,
        rm.quantity,
        rm.sort_order
    FROM items.recipe_materials rm
    ORDER BY rm.recipe_id, rm.sort_order;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION items.get_recipe_materials() IS 'automatic_get_api: Returns all material requirements across recipes';

CREATE OR REPLACE FUNCTION items.get_recipe_materials_by_key(p_id integer)
RETURNS TABLE(
    id integer,
    recipe_id integer,
    item_id integer,
    quantity integer,
    sort_order integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rm.id,
        rm.recipe_id,
        rm.item_id,
        rm.quantity,
        rm.sort_order
    FROM items.recipe_materials rm
    WHERE rm.recipe_id = p_id
    ORDER BY rm.sort_order;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION items.get_recipe_materials_by_key(p_id integer) IS 'automatic_get_api: Get materials for a specific recipe by ID';


-- ============================================================
-- SECTION 7: get_api Functions (Player Context Data)
-- ============================================================

CREATE OR REPLACE FUNCTION items.get_player_recipes(p_player_id integer)
RETURNS TABLE(
    recipe_id integer,
    category_id integer,
    name character varying,
    tier integer,
    gold_cost integer,
    level_requirement integer,
    crafting_time_minutes integer,
    image_url character varying,
    description character varying
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id as recipe_id,
        r.category_id,
        r.name,
        r.tier,
        r.gold_cost,
        r.level_requirement,
        r.crafting_time_minutes,
        r.image_url,
        r.description
    FROM items.recipes r
    WHERE r.id IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION items.get_player_recipes(p_player_id integer) IS 'get_api: Returns all available recipes for player to browse (fog-of-war: no, public catalog)';

CREATE OR REPLACE FUNCTION items.get_player_crafting_sessions(p_player_id integer)
RETURNS TABLE(
    id integer,
    recipe_id integer,
    name character varying,
    status character varying,
    started_at timestamptz,
    progress_percentage integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cs.id,
        cs.recipe_id,
        r.name,
        cs.status,
        cs.started_at,
        cs.progress_percentage
    FROM items.crafting_sessions cs
    JOIN items.recipes r ON cs.recipe_id = r.id
    WHERE cs.player_id = p_player_id
      AND cs.id IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION items.get_player_crafting_sessions(p_player_id integer) IS 'get_api: Returns player''s active crafting sessions with recipe details (fog-of-war: no, own sessions always visible)';

CREATE OR REPLACE FUNCTION items.get_player_inventory_items(p_player_id integer)
RETURNS TABLE(
    item_id integer,
    name character varying,
    quantity integer,
    slot_id integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        i.id as item_id,
        i.name,
        inv.quantity,
        inv.slot_id
    FROM inventory.inventory_items inv
    JOIN items.items i ON inv.item_id = i.id
    WHERE inv.owner_id = p_player_id
      AND inv.id IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION items.get_player_inventory_items(p_player_id integer) IS 'get_api: Returns player''s inventory items for checking material availability (fog-of-war: no, own inventory always visible)';


-- ============================================================
-- SECTION 8: action_api Functions (Player Actions)
-- ============================================================

CREATE OR REPLACE FUNCTION items.do_inspect_recipe(p_player_id integer, p_recipe_id integer)
RETURNS TABLE(status boolean, message text) AS $$
DECLARE
    v_player_exists boolean;
    v_recipe_exists boolean;
BEGIN
    -- Validate player exists and is active
    SELECT EXISTS(SELECT 1 FROM players.players WHERE id = p_player_id AND is_active = true) INTO v_player_exists;
    
    IF NOT v_player_exists THEN
        RETURN QUERY SELECT false, 'Player not found';
        RETURN;
    END IF;
    
    -- Verify recipe exists
    SELECT EXISTS(SELECT 1 FROM items.recipes WHERE id = p_recipe_id) INTO v_recipe_exists;
    
    IF NOT v_recipe_exists THEN
        RETURN QUERY SELECT false, 'Recipe does not exist';
        RETURN;
    END IF;
    
    -- Success: return true with message (frontend will fetch additional details via get_recipe_materials_by_key())
    RETURN QUERY SELECT true, 'Recipe inspected successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION items.do_inspect_recipe(p_player_id integer, p_recipe_id integer) IS 'action_api: Inspects a recipe and displays its full details in the UI panel (returns TABLE(status boolean, message text))';

CREATE OR REPLACE FUNCTION items.do_attempt_crafting(p_player_id integer, p_recipe_id integer)
RETURNS TABLE(status boolean, message text) AS $$
DECLARE
    v_player_exists boolean;
    v_recipe_exists boolean;
    v_gold_cost integer;
    v_level_req integer;
    v_tier integer;
    v_materials jsonb;
    v_has_gold boolean;
    v_missing_materials text := '';
    v_current_level integer;
BEGIN
    -- Validate player exists and is active
    SELECT EXISTS(SELECT 1 FROM players.players WHERE id = p_player_id AND is_active = true) INTO v_player_exists;
    
    IF NOT v_player_exists THEN
        RETURN QUERY SELECT false, 'Player not found';
        RETURN;
    END IF;
    
    -- Verify recipe exists
    SELECT EXISTS(SELECT 1 FROM items.recipes WHERE id = p_recipe_id) INTO v_recipe_exists;
    
    IF NOT v_recipe_exists THEN
        RETURN QUERY SELECT false, 'Recipe does not exist';
        RETURN;
    END IF;
    
    -- Fetch recipe details
    SELECT gold_cost, level_requirement, tier INTO v_gold_cost, v_level_req, v_tier
    FROM items.recipes WHERE id = p_recipe_id;
    
    -- Check player level requirement (get from existing player stats function)
    SELECT COALESCE(stats.level, 1) INTO v_current_level
    FROM attributes.player_stats stats
    WHERE stats.player_id = p_player_id AND stats.id IS NOT NULL;
    
    IF v_current_level < v_level_req THEN
        RETURN QUERY SELECT false, 'Level requirement not met (need ' || v_level_req || ', have ' || v_current_level || ')';
        RETURN;
    END IF;
    
    -- Check player has sufficient gold (get from existing player stats or inventory system)
    SELECT EXISTS(SELECT 1 FROM attributes.player_stats WHERE player_id = p_player_id AND gold >= v_gold_cost) INTO v_has_gold;
    
    IF NOT v_has_gold THEN
        RETURN QUERY SELECT false, 'Insufficient gold for crafting';
        RETURN;
    END IF;
    
    -- Get material requirements as JSONB for iteration
    SELECT jsonb_agg(jsonb_build_object('item_id', rm.item_id, 'quantity', rm.quantity)) INTO v_materials
    FROM items.recipe_materials rm WHERE rm.recipe_id = p_recipe_id;
    
    -- Check player has all required materials in inventory
    IF v_materials IS NOT NULL THEN
        FOR mat_item IN SELECT jsonb_extract_path_text(v_materials, i, 'item_id')::integer as item_id,
                                jsonb_extract_path_text(v_materials, i, 'quantity')::integer as needed_qty
                        FROM jsonb_array_elements(v_materials) AS j(i)
        LOOP
            -- Check if player has enough of this material (use existing get_player_inventory_items())
            SELECT EXISTS(
                SELECT 1 
                FROM inventory.inventory_items inv
                JOIN items.items it ON inv.item_id = it.id
                WHERE inv.owner_id = p_player_id 
                  AND it.id = mat_item.item_id 
                  AND inv.quantity >= mat_item.needed_qty
            ) INTO v_has_gold;
            
            IF NOT v_has_gold THEN
                SELECT i.name || ' (quantity needed: ' || mat_item.needed_qty::text || ')' INTO v_missing_materials
                FROM items.items i WHERE i.id = mat_item.item_id;
                
                RETURN QUERY SELECT false, 'Missing required materials: ' || v_missing_materials;
                RETURN;
            END IF;
        END LOOP;
    END IF;
    
    -- All checks passed - deduct gold and materials from player inventory
    -- Deduct gold (use existing function or update directly)
    UPDATE attributes.player_stats SET gold = gold - v_gold_cost WHERE player_id = p_player_id AND id IS NOT NULL;
    
    -- Remove materials from inventory (use existing do_move_or_swap_item() or create item removal logic)
    FOR mat_item IN SELECT jsonb_extract_path_text(v_materials, i, 'item_id')::integer as item_id,
                            jsonb_extract_path_text(v_materials, i, 'quantity')::integer as needed_qty
                    FROM jsonb_array_elements(v_materials) AS j(i)
    LOOP
        -- Remove required quantity from player's inventory slots (use existing inventory system functions)
        UPDATE inventory.inventory_items 
        SET quantity = GREATEST(quantity - mat_item.needed_qty, 0)
        WHERE owner_id = p_player_id AND item_id = mat_item.item_id;
        
        -- If slot becomes empty, optionally remove the item entry
        IF (SELECT quantity FROM inventory.inventory_items WHERE id IN (
            SELECT inv.slot_id FROM inventory.inventory_slots inv 
            JOIN inventory.inventory_items ii ON inv.id = ii.slot_id 
            WHERE ii.owner_id = p_player_id AND ii.item_id = mat_item.item_id
        )) IS NULL THEN
            DELETE FROM inventory.inventory_items WHERE item_id = mat_item.item_id AND owner_id = p_player_id;
        END IF;
    END LOOP;
    
    -- Create new crafted item in player's inventory (use existing do_add_item_to_inventory())
    INSERT INTO inventory.inventory_items (owner_id, item_id, quantity)
    VALUES (p_player_id, v_recipe_id, 1);
    
    -- Create completed entry in crafting_sessions table
    UPDATE items.crafting_sessions 
    SET status = 'completed', completed_at = NOW()
    WHERE player_id = p_player_id AND recipe_id = p_recipe_id;
    
    RETURN QUERY SELECT true, 'Crafting completed successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION items.do_attempt_crafting(p_player_id integer, p_recipe_id integer) IS 'action_api: Attempts to craft a recipe by deducting gold and materials from player inventory (returns TABLE(status boolean, message text))';

CREATE OR REPLACE FUNCTION items.do_cancel_crafting(p_player_id integer, p_session_id integer)
RETURNS TABLE(status boolean, message text) AS $$
DECLARE
    v_session_exists boolean;
    v_session_status character varying;
    v_session_belongs_to_player boolean;
BEGIN
    -- Verify session exists and belongs to this player
    SELECT EXISTS(
        SELECT 1 FROM items.crafting_sessions WHERE id = p_session_id AND player_id = p_player_id
    ) INTO v_session_exists;
    
    IF NOT v_session_exists THEN
        RETURN QUERY SELECT false, 'Crafting session does not exist';
        RETURN;
    END IF;
    
    -- Get current status to check if already completed
    SELECT status INTO v_session_status
    FROM items.crafting_sessions WHERE id = p_session_id;
    
    -- Cannot cancel completed sessions
    IF v_session_status = 'completed' THEN
        RETURN QUERY SELECT false, 'Cannot cancel completed crafting session';
        RETURN;
    END IF;
    
    -- Update status to cancelled (optionally refund materials/gold here)
    UPDATE items.crafting_sessions 
    SET status = 'cancelled', completed_at = NOW(
COMMIT;

-- End of Crafting Tree Migration
