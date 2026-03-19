-- ============================================================================
-- Quest System Migration
-- Description: Implements quest tracking system for PlayerQuestDiary component
-- Tables: 5 (4 reference + 1 main)
-- Functions: 8 (3 automatic_get_api, 2 get_api, 3 action_api)
-- Created: 2026-03-19
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- Reference Data Tables
-- ----------------------------------------------------------------------------

-- Quest type enumeration for categorizing quests
CREATE TABLE IF NOT EXISTS quest_types (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE quest_types IS 'Reference table for quest type categories';
COMMENT ON COLUMN quest_types.id IS 'Unique identifier for quest type';
COMMENT ON COLUMN quest_types.name IS 'Quest type name (main, side, dungeon, treasure, heroic)';
COMMENT ON COLUMN quest_types.description IS 'Description of the quest type';

-- Insert default quest types
INSERT INTO quest_types (id, name, description) VALUES
    (1, 'main', 'Main storyline quests that advance the primary narrative'),
    (2, 'side', 'Optional side quests for additional content and rewards'),
    (3, 'dungeon', 'Dungeon-specific exploration and combat quests'),
    (4, 'treasure', 'Treasure hunting and collection quests'),
    (5, 'heroic', 'High-difficulty heroic challenges')
ON CONFLICT (id) DO NOTHING;

-- Difficulty rating enumeration (1-5 scale)
CREATE TABLE IF NOT EXISTS difficulty_ratings (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(20) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE difficulty_ratings IS 'Reference table for quest difficulty levels';
COMMENT ON COLUMN difficulty_ratings.id IS 'Unique identifier for difficulty rating (1-5)';
COMMENT ON COLUMN difficulty_ratings.name IS 'Difficulty name (Easy, Medium, Hard, Very Hard, Extreme)';
COMMENT ON COLUMN difficulty_ratings.description IS 'Description of the difficulty level';

-- Insert default difficulty ratings
INSERT INTO difficulty_ratings (id, name, description) VALUES
    (1, 'easy', 'Simple quests suitable for beginners'),
    (2, 'medium', 'Moderate challenges requiring some experience'),
    (3, 'hard', 'Difficult quests for experienced players'),
    (4, 'very_hard', 'Very challenging quests with high rewards'),
    (5, 'extreme', 'Extreme difficulty - only for the bravest')
ON CONFLICT (id) DO NOTHING;

-- Faction status enumeration
CREATE TABLE IF NOT EXISTS faction_statuses (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(30) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE faction_statuses IS 'Reference table for faction relationship statuses';
COMMENT ON COLUMN faction_statuses.id IS 'Unique identifier for faction status';
COMMENT ON COLUMN faction_statuses.name IS 'Faction status (Ally, Neutral, Unknown)';
COMMENT ON COLUMN faction_statuses.description IS 'Description of the faction relationship';

-- Insert default faction statuses
INSERT INTO faction_statuses (id, name, description) VALUES
    (1, 'Ally', 'Friendly faction - cooperative relationship'),
    (2, 'Neutral', 'No established relationship'),
    (3, 'Unknown', 'Faction status not yet determined')
ON CONFLICT (id) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Main Quest Table
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS quests (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    quest_type_id INTEGER NOT NULL REFERENCES quest_types(id),
    difficulty_rating_id INTEGER NOT NULL REFERENCES difficulty_ratings(id),
    faction_status_id INTEGER REFERENCES faction_statuses(id),
    reward_xp INTEGER NOT NULL DEFAULT 0,
    reward_gold INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_completed BOOLEAN NOT NULL DEFAULT false,
    is_claimed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE quests IS 'Main quest table tracking all active and completed quests';
COMMENT ON COLUMN quests.id IS 'Unique identifier for the quest';
COMMENT ON COLUMN quests.title IS 'Quest title displayed to players';
COMMENT ON COLUMN quests.description IS 'Detailed quest description with objectives';
COMMENT ON COLUMN quests.quest_type_id IS 'Reference to quest type (FK)';
COMMENT ON COLUMN quests.difficulty_rating_id IS 'Reference to difficulty level (FK)';
COMMENT ON COLUMN quests.faction_status_id IS 'Current faction relationship status (FK, nullable)';
COMMENT ON COLUMN quests.reward_xp IS 'Experience points reward for completion';
COMMENT ON COLUMN quests.reward_gold IS 'Gold currency reward for completion';
COMMENT ON COLUMN quests.is_active IS 'Whether the quest is currently available';
COMMENT ON COLUMN quests.is_completed IS 'Whether the quest has been completed by a player';
COMMENT ON COLUMN quests.is_claimed IS 'Whether rewards have been claimed';
COMMENT ON COLUMN quests.created_at IS 'Quest creation timestamp';
COMMENT ON COLUMN quests.updated_at IS 'Last update timestamp for quest status changes';

-- Create index on quest_type_id for efficient filtering
CREATE INDEX IF NOT EXISTS idx_quests_quest_type_id ON quests(quest_type_id);

-- Create index on difficulty_rating_id for efficient filtering
CREATE INDEX IF NOT EXISTS idx_quests_difficulty_rating_id ON quests(difficulty_rating_id);

-- Create composite index for active quests by type and difficulty
CREATE INDEX IF NOT EXISTS idx_quests_active_filter ON quests(is_active, quest_type_id, difficulty_rating_id) WHERE is_active = true;

-- ----------------------------------------------------------------------------
-- Junction Tables (Many-to-Many Relationships)
-- ----------------------------------------------------------------------------

-- Quest requirements: items needed to accept/complete a quest
CREATE TABLE IF NOT EXISTS quest_requirements (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    quest_id INTEGER NOT NULL REFERENCES quests(id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES items.id,
    quantity INTEGER NOT NULL DEFAULT 1,
    is_optional BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE quest_requirements IS 'Junction table linking quests to required items';
COMMENT ON COLUMN quest_requirements.id IS 'Unique identifier for requirement entry';
COMMENT ON COLUMN quest_requirements.quest_id IS 'Reference to parent quest (FK)';
COMMENT ON COLUMN quest_requirements.item_id IS 'Reference to required item (FK)';
COMMENT ON COLUMN quest_requirements.quantity IS 'Quantity of item needed';
COMMENT ON COLUMN quest_requirements.is_optional IS 'Whether this requirement is optional for completion';

-- Create index on quest_id for efficient querying
CREATE INDEX IF NOT EXISTS idx_quest_requirements_quest_id ON quest_requirements(quest_id);

-- Quest rewards: items granted upon completing a quest
CREATE TABLE IF NOT EXISTS quest_rewards (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    quest_id INTEGER NOT NULL REFERENCES quests(id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES items.id,
    quantity INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE quest_rewards IS 'Junction table linking completed quests to reward items';
COMMENT ON COLUMN quest_rewards.id IS 'Unique identifier for reward entry';
COMMENT ON COLUMN quest_rewards.quest_id IS 'Reference to parent quest (FK)';
COMMENT ON COLUMN quest_rewards.item_id IS 'Reference to reward item (FK)';
COMMENT ON COLUMN quest_rewards.quantity IS 'Quantity of item awarded';

-- Create index on quest_id for efficient querying
CREATE INDEX IF NOT EXISTS idx_quest_rewards_quest_id ON quest_rewards(quest_id);

-- ----------------------------------------------------------------------------
-- API Functions - Automatic GET (Dictionary/Reference Data)
-- ----------------------------------------------------------------------------

-- Get all quest types
CREATE OR REPLACE FUNCTION quest_types.get_quest_types()
RETURNS SETOF quest_types AS $$
BEGIN
    RETURN QUERY SELECT * FROM quest_types ORDER BY id;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION quest_types.get_quest_types IS 'Returns all available quest type categories';

-- Get quest type by ID (for reference data)
CREATE OR REPLACE FUNCTION quest_types.get_quest_type_by_key(p_id INTEGER)
RETURNS SETOF quest_types AS $$
BEGIN
    RETURN QUERY SELECT * FROM quest_types WHERE id = p_id ORDER BY id;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION quest_types.get_quest_type_by_key IS 'Returns a specific quest type by ID';

-- Get all difficulty ratings
CREATE OR REPLACE FUNCTION difficulty_ratings.get_difficulty_ratings()
RETURNS SETOF difficulty_ratings AS $$
BEGIN
    RETURN QUERY SELECT * FROM difficulty_ratings ORDER BY id;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION difficulty_ratings.get_difficulty_ratings IS 'Returns all available difficulty rating levels';

-- Get difficulty rating by ID (for reference data)
CREATE OR REPLACE FUNCTION difficulty_ratings.get_difficulty_rating_by_key(p_id INTEGER)
RETURNS SETOF difficulty_ratings AS $$
BEGIN
    RETURN QUERY SELECT * FROM difficulty_ratings WHERE id = p_id ORDER BY id;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION difficulty_ratings.get_difficulty_rating_by_key IS 'Returns a specific difficulty rating by ID';

-- Get all faction statuses
CREATE OR REPLACE FUNCTION faction_statuses.get_faction_statuses()
RETURNS SETOF faction_statuses AS $$
BEGIN
    RETURN QUERY SELECT * FROM faction_statuses ORDER BY id;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION faction_statuses.get_faction_statuses IS 'Returns all available faction relationship statuses';

-- Get faction status by ID (for reference data)
CREATE OR REPLACE FUNCTION faction_statuses.get_faction_status_by_key(p_id INTEGER)
RETURNS SETOF faction_statuses AS $$
BEGIN
    RETURN QUERY SELECT * FROM faction_statuses WHERE id = p_id ORDER BY id;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION faction_statuses.get_faction_status_by_key IS 'Returns a specific faction status by ID';

-- ----------------------------------------------------------------------------
-- API Functions - GET (Player Context, Fog-of-War Aware)
-- ----------------------------------------------------------------------------

-- Get all active quests for the current player with optional status filtering
CREATE OR REPLACE FUNCTION quests.get_player_quests(p_player_id INTEGER, p_status_filter VARCHAR(20))
RETURNS TABLE(
    id INTEGER,
    title VARCHAR(200),
    description TEXT,
    quest_type_id INTEGER,
    quest_type_name VARCHAR(50),
    difficulty_rating_id INTEGER,
    difficulty_rating_name VARCHAR(20),
    faction_status_id INTEGER,
    faction_status_name VARCHAR(30),
    reward_xp INTEGER,
    reward_gold INTEGER,
    is_active BOOLEAN,
    is_completed BOOLEAN,
    is_claimed BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
) AS $$
BEGIN
    -- Return active quests for the player with optional status filtering
    RETURN QUERY
    SELECT 
        q.id,
        q.title,
        q.description,
        q.quest_type_id,
        qt.name AS quest_type_name,
        q.difficulty_rating_id,
        dr.name AS difficulty_rating_name,
        q.faction_status_id,
        fs.name AS faction_status_name,
        q.reward_xp,
        q.reward_gold,
        q.is_active,
        q.is_completed,
        q.is_claimed,
        q.created_at,
        q.updated_at
    FROM quests q
    JOIN quest_types qt ON q.quest_type_id = qt.id
    JOIN difficulty_ratings dr ON q.difficulty_rating_id = dr.id
    LEFT JOIN faction_statuses fs ON q.faction_status_id = fs.id
    WHERE q.is_active = true
      AND (p_status_filter IS NULL OR p_status_filter = 'all')
      AND (p_status_filter = 'active' AND q.is_completed = false)
      AND (p_status_filter = 'completed' AND q.is_completed = true)
      AND (p_status_filter = 'claimed' AND q.is_claimed = true)
    ORDER BY q.created_at DESC;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION quests.get_player_quests IS 'Returns all active quests for the current player with optional status filtering';

-- Get a specific quest by ID (for reference data and fog-of-war context)
CREATE OR REPLACE FUNCTION quests.get_quest_by_key(p_id INTEGER)
RETURNS SETOF quests AS $$
BEGIN
    RETURN QUERY SELECT * FROM quests WHERE id = p_id ORDER BY id;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION quests.get_quest_by_key IS 'Returns a specific quest by ID';

-- ----------------------------------------------------------------------------
-- API Functions - ACTION (Modifies Game State)
-- ----------------------------------------------------------------------------

-- Accept a quest for the current player
CREATE OR REPLACE FUNCTION quests.accept_quest(p_quest_id INTEGER, p_player_id INTEGER)
RETURNS TABLE(status BOOLEAN, message TEXT) AS $$
DECLARE
    v_quest RECORD;
    v_current_active BOOLEAN;
BEGIN
    -- Fetch the quest details
    SELECT * INTO v_quest FROM quests WHERE id = p_quest_id FOR UPDATE;
    
    -- Check if quest exists
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Quest not found' AS message;
        RETURN;
    END IF;
    
    -- Check if quest is active and available for acceptance
    v_current_active := v_quest.is_active AND NOT v_quest.is_completed;
    
    IF NOT v_current_active THEN
        RETURN QUERY SELECT false, 'Quest is not available for acceptance' AS message;
    END IF;
    
    -- Mark quest as accepted (set is_active to true if it was previously inactive)
    UPDATE quests 
    SET is_active = true, updated_at = now()
    WHERE id = p_quest_id;
    
    RETURN QUERY SELECT true, 'Quest accepted successfully' AS message;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION quests.accept_quest IS 'Accepts a quest for the current player';
COMMENT ON FUNCTION quests.accept_quest EXCEPTION WHEN OTHERS THEN RETURN QUERY SELECT false, SQLERRM AS message;

-- Complete a quest for the current player
CREATE OR REPLACE FUNCTION quests.complete_quest(p_quest_id INTEGER, p_player_id INTEGER)
RETURNS TABLE(status BOOLEAN, message TEXT) AS $$
DECLARE
    v_quest RECORD;
BEGIN
    -- Fetch the quest details with lock to prevent concurrent modifications
    SELECT * INTO v_quest FROM quests WHERE id = p_quest_id FOR UPDATE;
    
    -- Check if quest exists
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Quest not found' AS message;
        RETURN;
    END IF;
    
    -- Check if quest is active and can be completed
    IF NOT v_quest.is_active OR v_quest.is_completed THEN
        RETURN QUERY SELECT false, 'Quest cannot be completed (not active or already completed)' AS message;
    END IF;
    
    -- Mark quest as completed
    UPDATE quests 
    SET is_completed = true, updated_at = now()
    WHERE id = p_quest_id;
    
    RETURN QUERY SELECT true, 'Quest completed successfully' AS message;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION quests.complete_quest IS 'Marks a quest as completed for the current player';
COMMENT ON FUNCTION quests.complete_quest EXCEPTION WHEN OTHERS THEN RETURN QUERY SELECT false, SQLERRM AS message;

-- Claim rewards for a completed quest
CREATE OR REPLACE FUNCTION quests.claim_quest_rewards(p_quest_id INTEGER, p_player_id INTEGER)
RETURNS TABLE(status BOOLEAN, message TEXT) AS $$
DECLARE
    v_quest RECORD;
    v_reward_items JSONB;
BEGIN
    -- Fetch the quest details with lock to prevent concurrent modifications
    SELECT * INTO v_quest FROM quests WHERE id = p_quest_id FOR UPDATE;
    
    -- Check if quest exists
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Quest not found' AS message;
        RETURN;
    END IF;
    
    -- Check if quest is completed but rewards haven't been claimed
    IF NOT v_quest.is_completed OR v_quest.is_claimed THEN
        RETURN QUERY SELECT false, 'Quest rewards cannot be claimed (not completed or already claimed)' AS message;
    END IF;
    
    -- Mark quest as claimed and update reward tracking
    UPDATE quests 
    SET is_claimed = true, updated_at = now()
    WHERE id = p_quest_id;
    
    -- Build JSON of rewards for reference
    SELECT jsonb_agg(jsonb_build_object('item_id', qr.item_id, 'quantity', qr.quantity))
    INTO v_reward_items
    FROM quest_rewards qr
    WHERE qr.quest_id = p_quest_id;
    
    RETURN QUERY SELECT true, 'Quest rewards claimed successfully' AS message;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION quests.claim_quest_rewards IS 'Claims rewards for a completed quest';
COMMENT ON FUNCTION quests.claim_quest_rewards EXCEPTION WHEN OTHERS THEN RETURN QUERY SELECT false, SQLERRM AS message;

COMMIT;
