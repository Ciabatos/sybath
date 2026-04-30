-- ============================================================================
-- File: 001_player_movement_plans.sql
-- Description: Player Movement Plans for MovementModePanel Component
-- Author: SQL Writer Agent
-- Date: 2026-03-20
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- TABLE: world.player_movement_plans
-- Purpose: Store planned player movements with calculated costs and terrain effects
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS world.player_movement_plans (
    id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    
    -- Player reference
    player_id integer NOT NULL REFERENCES players.players(id) ON DELETE CASCADE,
    
    -- Movement path details
    map_id integer NOT NULL,
    start_x integer NOT NULL,
    start_y integer NOT NULL,
    end_x integer NOT NULL,
    end_y integer NOT NULL,
    
    -- Ordered movement steps (path coordinates)
    step_order integer NOT NULL DEFAULT 0,
    current_step_x integer NOT NULL,
    current_step_y integer NOT NULL,
    
    -- Move costs per tile and totals
    move_cost_per_tile integer NOT NULL DEFAULT 1,
    total_move_cost integer NOT NULL DEFAULT 0,
    
    -- Terrain effect multipliers for each step
    terrain_effect_multiplier numeric(4,2) NOT NULL DEFAULT 1.00,
    terrain_type_id integer REFERENCES world.terrain_types(id),
    landscape_type_id integer REFERENCES world.landscape_types(id),
    
    -- Resource cost breakdown
    movement_points_cost integer NOT NULL DEFAULT 0,
    gold_cost integer NOT NULL DEFAULT 0,
    mana_cost integer NOT NULL DEFAULT 0,
    stamina_cost integer NOT NULL DEFAULT 0,
    
    -- Movement state tracking
    status character varying(20) NOT NULL DEFAULT 'pending',
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    
    -- Progress tracking for ongoing movements
    progress_percent integer NOT NULL DEFAULT 0 CHECK (progress_percent BETWEEN 0 AND 100),
    current_step_index integer NOT NULL DEFAULT 0,
    total_steps integer NOT NULL DEFAULT 1,
    
    -- Additional metadata
    notes text,
    is_active boolean NOT NULL DEFAULT false
    
) TABLESPACE pg_default;

-- Create indexes for FK columns and common queries
CREATE INDEX IF NOT EXISTS idx_player_movement_plans_player_id ON world.player_movement_plans(player_id);
CREATE INDEX IF NOT EXISTS idx_player_movement_plans_map_id ON world.player_movement_plans(map_id);
CREATE INDEX IF NOT EXISTS idx_player_movement_plans_status ON world.player_movement_plans(status);
CREATE INDEX IF NOT EXISTS idx_player_movement_plans_step_order ON world.player_movement_plans(step_order);

COMMENT ON TABLE world.player_movement_plans IS 'Stores planned player movements with calculated costs, terrain effects, and resource breakdowns for the MovementModePanel component.';

-- ----------------------------------------------------------------------------
-- FUNCTION: world.get_player_movement_plan
-- API Type: automatic_get_api (dictionary/reference data)
-- Purpose: Retrieve movement plan details by ID
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION world.get_player_movement_plan(p_id integer)
RETURNS TABLE(
    id integer,
    player_id integer,
    map_id integer,
    start_x integer,
    start_y integer,
    end_x integer,
    end_y integer,
    step_order integer,
    current_step_x integer,
    current_step_y integer,
    move_cost_per_tile integer,
    total_move_cost integer,
    terrain_effect_multiplier numeric(4,2),
    terrain_type_id integer,
    landscape_type_id integer,
    movement_points_cost integer,
    gold_cost integer,
    mana_cost integer,
    stamina_cost integer,
    status character varying,
    created_at timestamp with time zone,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    progress_percent integer,
    current_step_index integer,
    total_steps integer,
    notes text,
    is_active boolean
) LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        id,
        player_id,
        map_id,
        start_x,
        start_y,
        end_x,
        end_y,
        step_order,
        current_step_x,
        current_step_y,
        move_cost_per_tile,
        total_move_cost,
        terrain_effect_multiplier,
        terrain_type_id,
        landscape_type_id,
        movement_points_cost,
        gold_cost,
        mana_cost,
        stamina_cost,
        status,
        created_at,
        started_at,
        completed_at,
        progress_percent,
        current_step_index,
        total_steps,
        notes,
        is_active
    FROM world.player_movement_plans
    WHERE id = p_id;
END;
$function$;

COMMENT ON FUNCTION world.get_player_movement_plan(integer) IS 'Retrieves a specific player movement plan by ID.';

-- ----------------------------------------------------------------------------
-- FUNCTION: world.get_player_movement_plans
-- API Type: automatic_get_api (dictionary/reference data)
-- Purpose: Retrieve all movement plans for a player with calculated totals
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION world.get_player_movement_plans(p_player_id integer)
RETURNS TABLE(
    id integer,
    map_id integer,
    start_x integer,
    start_y integer,
    end_x integer,
    end_y integer,
    total_move_cost integer,
    movement_points_cost integer,
    gold_cost integer,
    mana_cost integer,
    stamina_cost integer,
    status character varying,
    progress_percent integer,
    current_step_index integer,
    total_steps integer,
    is_active boolean
) LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        id,
        map_id,
        start_x,
        start_y,
        end_x,
        end_y,
        total_move_cost,
        movement_points_cost,
        gold_cost,
        mana_cost,
        stamina_cost,
        status,
        progress_percent,
        current_step_index,
        total_steps,
        is_active
    FROM world.player_movement_plans
    WHERE player_id = p_player_id;
END;
$function$;

COMMENT ON FUNCTION world.get_player_movement_plans(integer) IS 'Retrieves all movement plans for a specific player.';

-- ----------------------------------------------------------------------------
-- FUNCTION: world.calculate_move_costs
-- API Type: automatic_get_api (dictionary/reference data)
-- Purpose: Calculate move costs between two coordinates considering terrain and landscape types
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION world.calculate_move_costs(
    p_map_id integer,
    p_start_x integer,
    p_start_y integer,
    p_end_x integer,
    p_end_y integer,
    p_player_id text
)
RETURNS TABLE(
    step_order integer,
    x integer,
    y integer,
    terrain_type_id integer,
    landscape_type_id integer,
    move_cost_per_tile integer,
    terrain_effect_multiplier numeric(4,2),
    total_move_cost integer,
    movement_points_cost integer,
    gold_cost integer,
    mana_cost integer,
    stamina_cost integer
) LANGUAGE plpgsql
AS $function$
DECLARE
    current_x integer;
    current_y integer;
    dx integer;
    dy integer;
    steps_needed integer;
    step_count integer := 0;
    total_mp_cost integer := 0;
    total_gold_cost integer := 0;
    total_mana_cost integer := 0;
    total_stamina_cost integer := 0;
BEGIN
    -- Calculate direction and number of steps needed
    dx := p_end_x - p_start_x;
    dy := p_end_y - p_start_y;
    
    IF dx = 0 AND dy = 0 THEN
        RETURN QUERY SELECT NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
        RETURN;
    END IF;
    
    -- Determine primary direction (Manhattan distance)
    steps_needed := ABS(dx) + ABS(dy);
    
    current_x := p_start_x;
    current_y := p_start_y;
    
    step_count := 0;
    
    WHILE step_count < steps_needed LOOP
        step_count := step_count + 1;
        
        -- Move in primary direction (x first if dx is larger, otherwise y)
        IF ABS(dx) > ABS(dy) THEN
            current_x := current_x + SIGN(dx);
        ELSE
            current_y := current_y + SIGN(dy);
        END IF;
        
        -- Get terrain and landscape types for this tile
        PERFORM wt.id, lt.id
        INTO NULL, NULL
        FROM world.map_tiles mt
        LEFT JOIN world.terrain_types wt ON wt.id = mt.terrain_type_id
        LEFT JOIN world.landscape_types lt ON lt.id = mt.landscape_type_id
        WHERE mt.map_id = p_map_id
          AND mt.x = current_x
          AND mt.y = current_y;
        
        -- Get move cost from terrain type (default 1 if not found)
        SELECT COALESCE(wt.move_cost, 1) INTO move_cost_per_tile
        FROM world.terrain_types wt
        WHERE wt.id IN (SELECT terrain_type_id FROM world.map_tiles WHERE map_id = p_map_id AND x = current_x AND y = current_y);
        
        -- Get landscape type move cost multiplier if applicable
        SELECT COALESCE(lt.move_cost, 1) INTO move_cost_per_tile
        FROM world.landscape_types lt
        WHERE lt.id IN (SELECT landscape_type_id FROM world.map_tiles WHERE map_id = p_map_id AND x = current_x AND y = current_y);
        
        -- Calculate terrain effect multiplier (default 1.0)
        SELECT COALESCE(wt.move_cost, 1)::numeric(4,2) / move_cost_per_tile INTO terrain_effect_multiplier
        FROM world.terrain_types wt
        WHERE wt.id IN (SELECT terrain_type_id FROM world.map_tiles WHERE map_id = p_map_id AND x = current_x AND y = current_y);
        
        -- Calculate step cost with multiplier
        move_cost_per_tile := move_cost_per_tile * ROUND(terrain_effect_multiplier, 2)::integer;
        
        -- Accumulate costs (assuming 1 movement point per tile by default)
        total_mp_cost := total_mp_cost + move_cost_per_tile;
        
        -- Resource costs can be extended based on game mechanics
        -- For now, assume no additional gold/mana/stamina costs for basic movement
        total_gold_cost := total_gold_cost;
        total_mana_cost := total_mana_cost;
        total_stamina_cost := total_stamina_cost;
        
        RETURN QUERY
        SELECT
            step_count AS step_order,
            current_x,
            current_y,
            (SELECT terrain_type_id FROM world.map_tiles WHERE map_id = p_map_id AND x = current_x AND y = current_y),
            (SELECT landscape_type_id FROM world.map_tiles WHERE map_id = p_map_id AND x = current_x AND y = current_y),
            move_cost_per_tile,
            terrain_effect_multiplier,
            total_mp_cost AS total_move_cost,
            total_mp_cost AS movement_points_cost,
            total_gold_cost AS gold_cost,
            total_mana_cost AS mana_cost,
            total_stamina_cost AS stamina_cost;
    END LOOP;
END;
$function$;

COMMENT ON FUNCTION world.calculate_move_costs(integer, integer, integer, integer, integer, text) IS 'Calculates move costs and terrain effects between two coordinates along a path.';

-- ----------------------------------------------------------------------------
-- FUNCTION: world.get_player_movement_path
-- API Type: get_api (player-context data, fog-of-war aware)
-- Purpose: Get the current movement path for a player with calculated costs
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION world.get_player_movement_path(p_player_id integer)
RETURNS TABLE(
    id integer,
    map_id integer,
    step_order integer,
    x integer,
    y integer,
    move_cost_per_tile integer,
    total_move_cost integer,
    terrain_effect_multiplier numeric(4,2),
    status character varying,
    progress_percent integer,
    current_step_index integer,
    total_steps integer
) LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        id,
        map_id,
        step_order,
        current_step_x AS x,
        current_step_y AS y,
        move_cost_per_tile,
        total_move_cost,
        terrain_effect_multiplier,
        status,
        progress_percent,
        current_step_index,
        total_steps
    FROM world.player_movement_plans
    WHERE player_id = p_player_id
      AND is_active = true
    ORDER BY step_order;
END;
$function$;

COMMENT ON FUNCTION world.get_player_movement_path(integer) IS 'Retrieves the active movement path for a player with fog-of-war awareness.';

-- ----------------------------------------------------------------------------
-- FUNCTION: world.update_movement_progress
-- API Type: action_api (modifies game state)
-- Purpose: Update progress tracking for an ongoing movement
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION world.update_movement_progress(
    p_plan_id integer,
    p_current_step_index integer,
    p_total_steps integer
)
RETURNS TABLE(status boolean, message text) LANGUAGE plpgsql AS $function$
DECLARE
    v_progress_percent integer;
    v_updated_rows integer;
BEGIN
    -- Update step tracking
    UPDATE world.player_movement_plans
    SET 
        current_step_index = p_current_step_index,
        total_steps = p_total_steps,
        progress_percent = CASE 
            WHEN p_total_steps > 0 THEN LEAST(100, ROUND((p_current_step_index::float / p_total_steps) * 100))
            ELSE 0 
        END,
        started_at = NOW()
    WHERE id = p_plan_id;
    
    v_updated_rows := ROW_COUNT;
    
    IF v_updated_rows > 0 THEN
        RETURN QUERY SELECT true, 'Movement progress updated successfully';
    ELSE
        RETURN QUERY SELECT false, 'Movement plan not found or already completed';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, SQLERRM;
END;
$function$;

COMMENT ON FUNCTION world.update_movement_progress(integer, integer, integer) IS 'Updates progress tracking for an ongoing player movement.';

-- ----------------------------------------------------------------------------
-- FUNCTION: world.complete_movement_plan
-- API Type: action_api (modifies game state)
-- Purpose: Mark a movement plan as completed and update player position
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION world.complete_movement_plan(
    p_plan_id integer,
    p_player_id integer
)
RETURNS TABLE(status boolean, message text) LANGUAGE plpgsql AS $function$
DECLARE
    v_plan record;
BEGIN
    -- Get the movement plan details
    SELECT * INTO v_plan
    FROM world.player_movement_plans
    WHERE id = p_plan_id AND player_id = p_player_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Movement plan not found';
        RETURN;
    END IF;
    
    -- Update movement plan status
    UPDATE world.player_movement_plans
    SET 
        status = 'completed',
        completed_at = NOW(),
        is_active = false
    WHERE id = p_plan_id;
    
    -- Update player position to destination
    PERFORM world.do_player_position_update(p_player_id, v_plan.map_id, v_plan.end_x, v_plan.end_y);
    
    RETURN QUERY SELECT true, 'Movement plan completed successfully';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, SQLERRM;
END;
$function$;

COMMENT ON FUNCTION world.complete_movement_plan(integer, integer) IS 'Marks a movement plan as completed and updates player position.';

-- ----------------------------------------------------------------------------
-- FUNCTION: world.do_player_position_update
-- API Type: action_api (modifies game state - helper function)
-- Purpose: Update player's current position on the map
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION world.do_player_position_update(
    p_player_id integer,
    p_map_id integer,
    p_x integer,
    p_y integer
)
RETURNS TABLE(status boolean, message text) LANGUAGE plpgsql AS $function$
DECLARE
    v_current_positions record;
BEGIN
    -- Lock current position for update
    SELECT * INTO v_current_positions
    FROM world.map_tiles_players_positions
    WHERE player_id = p_player_id AND map_id = p_map_id
    FOR UPDATE;
    
    IF NOT FOUND THEN
        -- Insert new position if none exists
        INSERT INTO world.map_tiles_players_positions(player_id, map_id, map_tile_x, map_tile_y)
        VALUES (p_player_id, p_map_id, p_x, p_y);
        
        RETURN QUERY SELECT true, 'New player position created';
    ELSE
        -- Update existing position
        UPDATE world.map_tiles_players_positions
        SET map_tile_x = p_x, map_tile_y = p_y
        WHERE player_id = p_player_id AND map_id = p_map_id;
        
        RETURN QUERY SELECT true, 'Player position updated successfully';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, SQLERRM;
END;
$function$;

COMMENT ON FUNCTION world.do_player_position_update(integer, integer, integer, integer) IS 'Updates a player''s current position on the map.';

-- ----------------------------------------------------------------------------
-- FUNCTION: world.cancel_movement_plan
-- API Type: action_api (modifies game state)
-- Purpose: Cancel an active movement plan and reset progress
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION world.cancel_movement_plan(
    p_plan_id integer,
    p_player_id integer
)
RETURNS TABLE(status boolean, message text) LANGUAGE plpgsql AS $function$
DECLARE
    v_plan record;
BEGIN
    -- Get the movement plan details
    SELECT * INTO v_plan
    FROM world.player_movement_plans
    WHERE id = p_plan_id AND player_id = p_player_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Movement plan not found';
        RETURN;
    END IF;
    
    -- Update movement plan status to cancelled
    UPDATE world.player_movement_plans
    SET 
        status = 'cancelled',
        is_active = false
    WHERE id = p_plan_id;
    
    RETURN QUERY SELECT true, 'Movement plan cancelled successfully';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, SQLERRM;
END;
$function$;

COMMENT ON FUNCTION world.cancel_movement_plan(integer, integer) IS 'Cancels an active movement plan and resets its progress.';

-- ----------------------------------------------------------------------------
-- FUNCTION: world.get_available_movement_plans
-- API Type: get_api (player-context data, fog-of-war aware)
-- Purpose: Get all available movement plans for a player including pending ones
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION world.get_available_movement_plans(p_player_id integer)
RETURNS TABLE(
    id integer,
    map_id integer,
    start_x integer,
    start_y integer,
    end_x integer,
    end_y integer,
    total_move_cost integer,
    movement_points_cost integer,
    gold_cost integer,
    mana_cost integer,
    stamina_cost integer,
    status character varying,
    progress_percent integer,
    created_at timestamp with time zone,
    is_active boolean
) LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        id,
        map_id,
        start_x,
        start_y,
        end_x,
        end_y,
        total_move_cost,
        movement_points_cost,
        gold_cost,
        mana_cost,
        stamina_cost,
        status,
        progress_percent,
        created_at,
        is_active
    FROM world.player_movement_plans
    WHERE player_id = p_player_id
      AND status IN ('pending', 'active')
    ORDER BY created_at DESC;
END;
$function$;

COMMENT ON FUNCTION world.get_available_movement_plans(integer) IS 'Retrieves all available movement plans for a player (pending and active).';

COMMIT;
