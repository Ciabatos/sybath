# Skill Tree SQL Schema Documentation

## Overview

A comprehensive skill tree system for an RPG game with hierarchical progression, prerequisites, and visual tree connections. This schema builds on the existing `attributes.skills` table structure.

---

## Core Concept

- **Skills have hierarchical levels** (tree nodes)
- **Higher levels require lower levels + prerequisites**
- **Players unlock nodes by meeting requirements**
- **Visual tree connections between related skills

---

## Database Schema

### 1. Skill Tree Categories / Branches

```sql
CREATE TABLE attributes.skill_tree_branches (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    parent_branch_id INTEGER REFERENCES attributes.skill_tree_branches(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Purpose:** Organize skills into categories (Combat, Magic, Stealth, etc.) with hierarchical branch structure.

---

### 2. Skill Levels (Tree Nodes)

```sql
CREATE TABLE attributes.skill_levels (
    id SERIAL PRIMARY KEY,
    skill_id INTEGER NOT NULL REFERENCES attributes.skills(id) ON DELETE CASCADE,
    level_number INTEGER NOT NULL CHECK (level_number >= 1),
    
    -- Level properties
    name VARCHAR(100),
    description TEXT,
    image_url VARCHAR(255),
    max_value INTEGER NOT NULL DEFAULT 100,
    
    -- Prerequisites: must have this skill at previous level
    requires_skill_id INTEGER REFERENCES attributes.skills(id) ON DELETE SET NULL,
    requires_skill_level INTEGER DEFAULT 1,
    
    -- Alternative prerequisites (OR conditions)
    alternative_requirement_type VARCHAR(50), -- 'stat' | 'ability' | 'quest'
    alternative_stat_id INTEGER REFERENCES attributes.stats(id) ON DELETE SET NULL,
    alternative_min_value INTEGER DEFAULT 1,
    alternative_ability_id INTEGER REFERENCES attributes.abilities(id) ON DELETE SET NULL,
    
    UNIQUE(skill_id, level_number),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Purpose:** Define individual skill levels with prerequisites and unlock requirements.

---

### 3. Skill Tree Connections (Visual Links)

```sql
CREATE TABLE attributes.skill_tree_connections (
    id SERIAL PRIMARY KEY,
    source_skill_level_id INTEGER NOT NULL REFERENCES attributes.skill_levels(id) ON DELETE CASCADE,
    target_skill_level_id INTEGER NOT NULL REFERENCES attributes.skill_levels(id) ON DELETE CASCADE,
    
    -- Connection properties
    connection_type VARCHAR(50) NOT NULL CHECK (connection_type IN ('prerequisite', 'related', 'alternative', 'specialization')),
    description TEXT,
    
    UNIQUE(source_skill_level_id, target_skill_level_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Purpose:** Create visual links between skill nodes for tree visualization.

---

### 4. Player Skill Tree Progression

```sql
CREATE TABLE attributes.player_skill_tree_progress (
    id SERIAL PRIMARY KEY,
    player_id INTEGER NOT NULL REFERENCES players.players(id) ON DELETE CASCADE,
    skill_id INTEGER NOT NULL REFERENCES attributes.skills(id) ON DELETE CASCADE,
    
    -- Current unlocked level
    current_level INTEGER NOT NULL DEFAULT 1 CHECK (current_level >= 1),
    max_unlocked_level INTEGER NOT NULL DEFAULT 1 CHECK (max_unlocked_level >= 1),
    
    -- Experience/progress toward next level
    experience INTEGER NOT NULL DEFAULT 0,
    experience_to_next_level INTEGER NOT NULL DEFAULT 100,
    
    UNIQUE(player_id, skill_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Purpose:** Track each player's unlocked levels and XP progress per skill.

---

### 5. Skill Tree Unlock History (Audit Log)

```sql
CREATE TABLE attributes.skill_tree_unlock_history (
    id SERIAL PRIMARY KEY,
    player_id INTEGER NOT NULL REFERENCES players.players(id) ON DELETE CASCADE,
    skill_id INTEGER NOT NULL REFERENCES attributes.skills(id) ON DELETE CASCADE,
    level_number INTEGER NOT NULL,
    
    -- Unlock details
    unlock_type VARCHAR(50) NOT NULL CHECK (unlock_type IN ('level_up', 'prerequisite_met', 'special_event')),
    experience_gained INTEGER DEFAULT 0,
    unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Purpose:** Audit trail of all skill unlocks for debugging and analytics.

---

### 6. Skill Tree Quest/Event Requirements (Optional)

```sql
CREATE TABLE attributes.skill_tree_quest_requirements (
    id SERIAL PRIMARY KEY,
    skill_level_id INTEGER NOT NULL REFERENCES attributes.skill_levels(id) ON DELETE CASCADE,
    quest_id VARCHAR(100), -- External quest identifier or NULL for auto-unlock
    
    -- Quest-specific requirements
    required_item_id INTEGER REFERENCES items.items(id) ON DELETE SET NULL,
    required_quantity INTEGER DEFAULT 1,
    
    UNIQUE(skill_level_id, quest_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Purpose:** Enable quest-based or event-triggered skill unlocks.

---

## Indexes for Performance

```sql
CREATE INDEX idx_skill_levels_skill_id ON attributes.skill_levels(skill_id);
CREATE INDEX idx_skill_levels_prereq ON attributes.skill_levels(requires_skill_id, requires_skill_level);
CREATE INDEX idx_player_skill_tree_progress ON attributes.player_skill_tree_progress(player_id, skill_id);
CREATE INDEX idx_skill_tree_connections_source ON attributes.skill_tree_connections(source_skill_level_id);
CREATE INDEX idx_skill_tree_connections_target ON attributes.skill_tree_connections(target_skill_level_id);
```

---

## Views for Common Queries

### View: Available Skill Levels for a Player

```sql
CREATE VIEW attributes.available_skill_levels AS
SELECT 
    sl.id,
    sl.skill_id,
    s.name AS skill_name,
    sl.level_number,
    sl.name AS level_name,
    sl.description AS level_description,
    sl.image_url,
    sl.max_value,
    
    -- Player's current state for this skill
    pstp.current_level AS player_current_level,
    pstp.max_unlocked_level AS player_max_level,
    pstp.experience AS player_experience,
    pstp.experience_to_next_level,
    
    -- Unlock status
    CASE 
        WHEN sl.level_number <= COALESCE(pstp.max_unlocked_level, 1) THEN 'unlocked'
        WHEN sl.level_number = (pstp.current_level + 1) AND pstp.current_level IS NOT NULL THEN 'available'
        ELSE 'locked'
    END AS unlock_status,
    
    -- Prerequisites
    sl.requires_skill_id,
    sl.requires_skill_level
    
FROM attributes.skill_levels sl
JOIN attributes.skills s ON sl.skill_id = s.id
LEFT JOIN attributes.player_skill_tree_progress pstp 
    ON pstp.skill_id = sl.skill_id 
    AND pstp.player_id = 1; -- Replace with dynamic player_id in actual query
```

**Purpose:** Show all skill levels with unlock status for a specific player.

---

### View: Skill Tree Branch Hierarchy

```sql
CREATE VIEW attributes.skill_branch_hierarchy AS
WITH RECURSIVE branches AS (
    SELECT id, name, description, image_url, parent_branch_id, 0 as depth
    FROM attributes.skill_tree_branches WHERE parent_branch_id IS NULL
    
    UNION ALL
    
    SELECT b.id, b.name, b.description, b.image_url, b.parent_branch_id, br.depth + 1
    FROM attributes.skill_tree_branches b
    JOIN branches br ON b.parent_branch_id = br.id
)
SELECT * FROM branches ORDER BY depth, name;
```

**Purpose:** Display hierarchical branch structure with parent-child relationships.

---

### View: Player's Skill Tree Progress Summary

```sql
CREATE VIEW attributes.player_skill_tree_summary AS
SELECT 
    p.id AS player_id,
    p.name AS player_name,
    s.id AS skill_id,
    s.name AS skill_name,
    s.description AS skill_description,
    s.image AS skill_image,
    
    pstp.current_level,
    pstp.max_unlocked_level,
    pstp.experience,
    pstp.experience_to_next_level,
    
    -- Progress percentage
    ROUND(LEAST(100.0, (pstp.experience::numeric / NULLIF(pstp.experience_to_next_level, 0)) * 100), 2) AS progress_percent
    
FROM players p
JOIN attributes.skills s ON TRUE
LEFT JOIN attributes.player_skill_tree_progress pstp 
    ON pstp.player_id = p.id AND pstp.skill_id = s.id;
```

**Purpose:** Summary view showing all skills and player progress across the entire tree.


---

## Functions for Skill Tree Operations

### Function: Check if Skill Level is Unlockable

```sql
CREATE OR REPLACE FUNCTION attributes.is_skill_level_unlockable(
    p_player_id INTEGER,
    p_skill_id INTEGER,
    p_level_number INTEGER
)
RETURNS TABLE(
    can_unlock BOOLEAN,
    reason TEXT,
    missing_prerequisites JSONB
) AS $$
DECLARE
    v_skill_level RECORD;
    v_prereq_skill_level RECORD;
    v_player_stat_value INTEGER;
    v_player_ability_value INTEGER;
BEGIN
    -- Get the skill level definition
    SELECT * INTO v_skill_level
    FROM attributes.skill_levels
    WHERE skill_id = p_skill_id AND level_number = p_level_number
    LIMIT 1;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Skill level does not exist', '{}'::jsonb;
    END IF;
    
    -- Check direct prerequisite (previous level of same skill)
    IF v_skill_level.requires_skill_id IS NOT NULL AND v_skill_level.requires_skill_level > 0 THEN
        SELECT * INTO v_prereq_skill_level
        FROM attributes.skill_levels
        WHERE skill_id = v_skill_level.requires_skill_id 
          AND level_number = v_skill_level.requires_skill_level;
        
        IF NOT FOUND THEN
            RETURN QUERY SELECT FALSE, 'Prerequisite skill level does not exist', '{}'::jsonb;
        END IF;
        
        -- Check if player has met prerequisite
        SELECT INTO v_player_stat_value
        FROM attributes.player_skills
        WHERE player_id = p_player_id AND skill_id = v_skill_level.requires_skill_id
        LIMIT 1;
        
        IF v_player_stat_value IS NULL OR v_player_stat_value < v_prereq_skill_level.max_value THEN
            RETURN QUERY SELECT FALSE, 'Prerequisite skill level not met', 
                jsonb_build_object('skill_id', v_skill_level.requires_skill_id, 
                                   'required_level', v_skill_level.requires_skill_level);
        END IF;
    END IF;
    
    -- Check alternative requirements (stat-based)
    IF v_skill_level.alternative_requirement_type = 'stat' THEN
        SELECT INTO v_player_stat_value
        FROM attributes.player_stats
        WHERE player_id = p_player_id AND stat_id = v_skill_level.alternative_stat_id
        LIMIT 1;
        
        IF v_player_stat_value IS NULL OR v_player_stat_value < v_skill_level.alternative_min_value THEN
            RETURN QUERY SELECT FALSE, 'Required stat not met', 
                jsonb_build_object('stat_id', v_skill_level.alternative_stat_id,
                                   'required_value', v_skill_level.alternative_min_value);
        END IF;
    ELSIF v_skill_level.alternative_requirement_type = 'ability' THEN
        SELECT INTO v_player_ability_value
        FROM attributes.player_abilities
        WHERE player_id = p_player_id AND ability_id = v_skill_level.alternative_ability_id
        LIMIT 1;
        
        IF v_player_ability_value IS NULL OR v_player_ability_value < 1 THEN
            RETURN QUERY SELECT FALSE, 'Required ability not met', 
                jsonb_build_object('ability_id', v_skill_level.alternative_ability_id);
        END IF;
    END IF;
    
    -- Check if already unlocked
    SELECT INTO v_prereq_skill_level
    FROM attributes.player_skill_tree_progress
    WHERE player_id = p_player_id AND skill_id = p_skill_id 
      AND max_unlocked_level >= p_level_number;
      
    IF FOUND THEN
        RETURN QUERY SELECT FALSE, 'Skill level already unlocked', '{}'::jsonb;
    END IF;
    
    -- All checks passed!
    RETURN QUERY SELECT TRUE, 'Ready to unlock', '{}'::jsonb;
END;
$$ LANGUAGE plpgsql;
```

**Purpose:** Validate if a player can unlock a specific skill level based on prerequisites.

---

### Function: Unlock Skill Level for Player

```sql
CREATE OR REPLACE FUNCTION attributes.unlock_skill_level(
    p_player_id INTEGER,
    p_skill_id INTEGER,
    p_level_number INTEGER,
    p_experience_gained INTEGER DEFAULT 100
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    new_max_level INTEGER,
    new_experience INTEGER,
    experience_to_next_level INTEGER
) AS $$
DECLARE
    v_skill_level RECORD;
    v_current_progress RECORD;
    v_new_max_level INTEGER;
    v_new_experience INTEGER;
    v_exp_to_next INTEGER;
BEGIN
    -- Get skill level definition
    SELECT * INTO v_skill_level
    FROM attributes.skill_levels
    WHERE skill_id = p_skill_id AND level_number = p_level_number
    LIMIT 1;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Skill level does not exist', NULL, NULL, NULL;
    END IF;
    
    -- Check if unlockable
    PERFORM attributes.is_skill_level_unlockable(p_player_id, p_skill_id, p_level_number);
    
    -- Get current progress
    SELECT * INTO v_current_progress
    FROM attributes.player_skill_tree_progress
    WHERE player_id = p_player_id AND skill_id = p_skill_id
    LIMIT 1;
    
    IF NOT FOUND THEN
        -- First time unlocking this skill
        v_new_max_level := p_level_number;
        v_new_experience := p_experience_gained;
        v_exp_to_next := v_skill_level.max_value;
        
        INSERT INTO attributes.player_skill_tree_progress (player_id, skill_id, current_level, max_unlocked_level, experience, experience_to_next_level)
        VALUES (p_player_id, p_skill_id, p_level_number, p_level_number, p_experience_gained, v_exp_to_next);
    ELSE
        -- Update existing progress
        v_new_max_level := GREATEST(v_current_progress.max_unlocked_level, p_level_number);
        v_new_experience := COALESCE(v_current_progress.experience + p_experience_gained, 0);
        
        UPDATE attributes.player_skill_tree_progress
        SET current_level = LEAST(p_level_number, v_current_progress.current_level + 1),
            max_unlocked_level = GREATEST(v_current_progress.max_unlocked_level, p_level_number),
            experience = COALESCE(v_current_progress.experience + p_experience_gained, 0)
        WHERE player_id = p_player_id AND skill_id = p_skill_id;
        
        v_new_experience := attributes.player_skill_tree_progress.current_level;
        SELECT experience_to_next_level INTO v_exp_to_next
        FROM attributes.player_skill_tree_progress
        WHERE player_id = p_player_id AND skill_id = p_skill_id;
    END IF;
    
    -- Record unlock history
    INSERT INTO attributes.skill_tree_unlock_history (player_id, skill_id, level_number, unlock_type)
    VALUES (p_player_id, p_skill_id, p_level_number, 'level_up');
    
    RETURN QUERY SELECT TRUE, 'Skill level unlocked successfully', v_new_max_level, 
                      COALESCE(v_current_progress.experience + p_experience_gained, 0), v_exp_to_next;
END;
$$ LANGUAGE plpgsql;
```

**Purpose:** Unlock a skill level for a player and record the progression.

---

### Function: Get Skill Tree Visualization Data

```sql
CREATE OR REPLACE FUNCTION attributes.get_skill_tree_visualization(
    p_player_id INTEGER
)
RETURNS TABLE(
    node_id INTEGER,
    skill_name VARCHAR,
    level_number INTEGER,
    unlock_status VARCHAR,
    progress_percent NUMERIC,
    x_coord INTEGER,
    y_coord INTEGER,
    branch_name VARCHAR
) AS $$
DECLARE
    v_branch RECORD;
BEGIN
    -- Get all skills with their levels and player progress
    WITH skill_data AS (
        SELECT 
            sl.id as node_id,
            s.name as skill_name,
            sl.level_number,
            CASE 
                WHEN sl.level_number <= COALESCE(pstp.max_unlocked_level, 1) THEN 'unlocked'
                WHEN sl.level_number = (pstp.current_level + 1) AND pstp.current_level IS NOT NULL THEN 'available'
                ELSE 'locked'
            END as unlock_status,
            ROUND(LEAST(100.0, (COALESCE(pstp.experience, 0)::numeric / NULLIF(sl.max_value, 0)) * 100), 2) as progress_percent,
            sb.name as branch_name
        FROM attributes.skill_levels sl
        JOIN attributes.skills s ON sl.skill_id = s.id
        LEFT JOIN attributes.player_skill_tree_progress pstp 
            ON pstp.skill_id = sl.skill_id AND pstp.player_id = p_player_id
        LEFT JOIN attributes.skill_tree_branches sb ON sb.parent_branch_id IS NULL -- Top level branches
    )
    SELECT * FROM skill_data;
END;
$$ LANGUAGE plpgsql;
```

**Purpose:** Get all skill nodes with unlock status for rendering the tree visualization.

---

## Additional Helper Functions

### Function: Get Unlockable Skill Levels for a Player

```sql
CREATE OR REPLACE FUNCTION attributes.get_unlockable_skill_levels(
    p_player_id INTEGER
)
RETURNS TABLE(
    skill_id INTEGER,
    skill_name VARCHAR,
    level_number INTEGER,
    branch_name VARCHAR,
    experience_required INTEGER,
    prerequisite_met BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sl.skill_id,
        s.name as skill_name,
        sl.level_number,
        sb.name as branch_name,
        sl.max_value as experience_required,
        CASE WHEN pstp.current_level >= sl.level_number - 1 THEN TRUE ELSE FALSE END as prerequisite_met
    FROM attributes.skill_levels sl
    JOIN attributes.skills s ON sl.skill_id = s.id
    LEFT JOIN attributes.skill_tree_branches sb ON sb.parent_branch_id IS NULL
    LEFT JOIN attributes.player_skill_tree_progress pstp 
        ON pstp.skill_id = sl.skill_id AND pstp.player_id = p_player_id
    WHERE pstp.max_unlocked_level = COALESCE(pstp.current_level, 0)
      AND sl.level_number = (COALESCE(pstp.current_level, 0) + 1);
END;
$$ LANGUAGE plpgsql;
```

**Purpose:** Find all skill levels that a player can currently unlock.

---

### Function: Get Skill Tree Statistics for Player

```sql
CREATE OR REPLACE FUNCTION attributes.get_skill_tree_stats(
    p_player_id INTEGER
)
RETURNS TABLE(
    total_skills INTEGER,
    unlocked_levels INTEGER,
    locked_levels INTEGER,
    total_xp_earned INTEGER,
    progress_percentage NUMERIC
) AS $$
DECLARE
    v_total_levels INTEGER;
    v_unlocked_levels INTEGER;
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(DISTINCT pst.skill_id) as total_skills,
        COALESCE(SUM(CASE WHEN sl.level_number <= pst.max_unlocked_level THEN 1 ELSE 0 END), 0) as unlocked_levels,
        COALESCE(SUM(CASE WHEN sl.level_number > pst.max_unlocked_level THEN 1 ELSE 0 END), 0) as locked_levels,
        COALESCE(SUM(pst.experience), 0) as total_xp_earned,
        ROUND(LEAST(100.0, (COALESCE(SUM(pst.experience), 0)::numeric / NULLIF((SELECT SUM(max_value) FROM attributes.skill_levels WHERE skill_id IN (SELECT DISTINCT skill_id FROM attributes.player_skill_tree_progress WHERE player_id = p_player_id)), 0)) * 100), 2) as progress_percentage
    FROM attributes.player_skill_tree_progress pst;
END;
$$ LANGUAGE plpgsql;
```

**Purpose:** Get overall statistics about a player's skill tree progression.

---

### View: Skill Tree Path Visualization

```sql
CREATE VIEW attributes.skill_tree_path AS
WITH RECURSIVE skill_path AS (
    -- Starting nodes (level 1 of all skills)
    SELECT 
        sl.id as node_id,
        s.name as skill_name,
        sl.level_number,
        sl.requires_skill_id,
        sl.requires_skill_level,
        0 as depth,
        ARRAY[sl.id] as path
    FROM attributes.skill_levels sl
    JOIN attributes.skills s ON sl.skill_id = s.id
    WHERE sl.level_number = 1
    
    UNION ALL
    
    -- Child nodes (higher levels)
    SELECT 
        sl2.id,
        s2.name,
        sl2.level_number,
        sl2.requires_skill_id,
        sl2.requires_skill_level,
        sp.depth + 1,
        sp.path || sl2.id
    FROM attributes.skill_levels sl2
    JOIN attributes.skills s2 ON sl2.skill_id = s2.id
    JOIN skill_path sp ON sp.requires_skill_id = sl2.skill_id 
                       AND sp.requires_skill_level = sl2.level_number - 1
)
SELECT * FROM skill_path ORDER BY depth, node_id;
```

**Purpose:** Visual path through the skill tree showing progression order.


---

## Sample Data Insertion (Optional)

### Insert Sample Skill Tree Branches

```sql
INSERT INTO attributes.skill_tree_branches (name, description, image_url) VALUES
('Combat', 'Master the art of battle', 'combat_branch.png'),
('Magic', 'Harness arcane powers', 'magic_branch.png'),
('Stealth', 'Become a master assassin', 'stealth_branch.png');
```

### Insert Sample Skills with Levels

```sql
INSERT INTO attributes.skills (id, name, description, image) VALUES
(1, 'Sword Mastery', 'Progressive sword fighting techniques', 'sword_skill.png'),
(2, 'Fire Magic', 'Control and wield fire spells', 'fire_magic.png'),
(3, 'Shadow Step', 'Move through shadows undetected', 'shadow_step.png');

INSERT INTO attributes.skill_levels (skill_id, level_number, name, description, max_value) VALUES
-- Sword Mastery levels
(1, 1, 'Basic Strike', 'Learn fundamental sword strikes', 20),
(1, 2, 'Advanced Guard', 'Master defensive techniques', 40),
(1, 3, 'Combo Attack', 'Chain attacks together', 60),
(1, 4, 'Critical Hit', 'Land devastating blows', 80),
(1, 5, 'Mastery', 'Perfect swordsmanship', 100);

-- Fire Magic levels (similar structure)
(2, 1, 'Spark', 'Create small flames', 20),
(2, 2, 'Fireball', 'Launch fire projectiles', 40),
(2, 3, 'Inferno', 'Unleash massive fire damage', 60),
(2, 4, 'Combustion', 'Explode with pure energy', 80),
(2, 5, 'Pyromancy Mastery', 'Master all fire arts', 100);

-- Shadow Step levels (similar structure)
(3, 1, 'Shadow Walk', 'Move silently in shadows', 20),
(3, 2, 'Phantom Strike', 'Attack from darkness', 40),
(3, 3, 'Vanish', 'Disappear completely', 60),
(3, 4, 'Nightmare', 'Haunt your enemies', 80),
(3, 5, 'Shadow Master', 'Rule the shadows', 100);
```

### Insert Skill Tree Connections (Visual Links)

```sql
INSERT INTO attributes.skill_tree_connections (source_skill_level_id, target_skill_level_id, connection_type, description) VALUES
-- Sword Mastery progression chain
((SELECT id FROM attributes.skill_levels WHERE skill_id=1 AND level_number=1),
 (SELECT id FROM attributes.skill_levels WHERE skill_id=1 AND level_number=2),
 'prerequisite', 'Required for next level'),

((SELECT id FROM attributes.skill_levels WHERE skill_id=1 AND level_number=2),
 (SELECT id FROM attributes.skill_levels WHERE skill_id=1 AND level_number=3),
 'prerequisite', 'Required for next level');

-- Add more connections as needed...
```

---

## Component Flow Spec: Skill Tree UI

### Component: `SkillTreeDisplay`

#### Purpose
Visual skill tree interface showing player's progression, unlocked levels, and available upgrades across different branches.

---

### Data Sources (on mount)

```typescript
// 1. Get all skills for the tree
get_skills() → SETOF attributes.skills
  Used for: Populating skill nodes in the tree

// 2. Get player's current skill values
get_player_skills(p_player_id) → TABLE(skill_id, value, name)
  Used for: Displaying current skill levels/values

// 3. Get all skill levels (tree nodes)
skill_levels table JOIN skills
  Used for: Building the tree structure with levels

// 4. Get player's skill tree progress
player_skill_tree_progress(player_id, skill_id)
  Used for: Showing unlocked/locked status and XP progress

// 5. Get skill branch hierarchy (optional filtering)
skill_tree_branches table
  Used for: Grouping skills into branches (Combat/Magic/Stealth)

// 6. Get skill tree connections (visual links)
skill_tree_connections(source, target, connection_type)
  Used for: Drawing lines between related nodes
```

---

### UI States

#### **Loading**
- Show skeleton loader for each branch section
- Display "Loading your skills..." overlay
- Spinner on skill cards while fetching data

#### **Empty** (No progress yet)
- Show empty state illustration
- Text: "You haven't unlocked any skills yet"
- Primary button: "Start Training" → navigates to first available skill

#### **Populated** (Main UI)

```
┌─────────────────────────────────────────────────────────────┐
│  SKILL TREE                                                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ COMBAT       │  │ MAGIC        │  │ STEALTH      │     │
│  │ Branch       │  │ Branch       │  │ Branch       │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                             │
│  ┌─────────────────────────────────────────────────┐      │
│  │ SWORD MASTERY                                    │      │
│  ├─────────────────────────────────────────────────┤      │
│  │ Level 1: Basic Strike        [✓ UNLOCKED]      │      │
│  │   XP: ████████████░░░░░░░░ 80/100             │      │
│  ├─────────────────────────────────────────────────┤      │
│  │ Level 2: Advanced Guard       [✓ UNLOCKED]     │      │
│  │   XP: ████████░░░░░░░░░░░░ 40/100             │      │
│  ├─────────────────────────────────────────────────┤      │
│  │ Level 3: Combo Attack         [🔒 LOCKED]      │      │
│  │   Req: Advanced Guard (Lvl 2)                  │      │
│  │   [Unlock - Cost: 60 XP]                       │      │
│  ├─────────────────────────────────────────────────┤      │
│  │ Level 4: Critical Hit          [🔒 LOCKED]     │      │
│  │ Level 5: Mastery                [🔒 LOCKED]     │      │
│  └─────────────────────────────────────────────────┘      │
│                                                             │
│  [Fire Magic Branch - Similar Structure]                  │
│  [Shadow Step Branch - Similar Structure]                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### **Error** (Fetch failure)
- Show error message: "Failed to load skill tree"
- Retry button
- Support ticket link

---

### Actions

#### **"Unlock Level" Button** (on locked skill level)

```typescript
Calls: do_gather_resources_on_map_tile() OR custom action
Params: 
  - p_player_id: integer
  - p_skill_id: integer  
  - p_level_number: integer
  - p_experience_amount: integer

On success (status=true):
  - Show toast: "Level X unlocked! +100 XP"
  - Re-fetch player_skills to update displayed values
  - Re-fetch player_skill_tree_progress to show new progress bar
  - Update UI optimistically: change lock icon to unlock, show new XP bar

On failure (status=false):
  - Show message field with error text from API response
  - Example: "Not enough resources. Need 50 wood."
  - Highlight the button in red

Pending state:
  - Disable button during action
  - Show spinner icon on button
  - Change text to "Unlocking..."
```

#### **"Filter by Branch" Dropdown**

```typescript
Calls: automatic_get_skill_tree_branches() → SETOF attributes.skill_tree_branches
Used for: Filtering visible skill branches

Options: All, Combat, Magic, Stealth
```

---

### Validation (Client-Side)

Before calling unlock action:
1. **Check if level exists**: `skill_level.level_number > 0`
2. **Check if locked**: `unlock_status === 'locked'`
3. **Check prerequisites met**: Verify prerequisite skill level is unlocked via `get_player_skills()` data
4. **Check XP available**: Compare player's current XP vs required amount

---

### Post-Action Refresh

After successful unlock:
1. Re-call `get_player_skills(p_player_id)` to refresh displayed values
2. Re-fetch `player_skill_tree_progress` to update progress bars
3. Trigger animation effect on newly unlocked node
4. Update local cache for optimistic UI updates

---

## Integration with Existing API

### Compatible Tables (Already Exist)
- ✅ `attributes.skills` - Base skill definitions
- ✅ `attributes.player_skills` - Player's acquired skills with values
- ✅ `attributes.ability_skill_requirements` - Abilities that require certain skills
- ✅ `attributes.stats` - Character stats for alternative requirements
- ✅ `attributes.abilities` - Abilities for alternative requirements

### New Tables Added
- ✅ `skill_tree_branches` - Organize skills into categories
- ✅ `skill_levels` - Individual tree nodes with prerequisites  
- ✅ `skill_tree_connections` - Visual links between nodes
- ✅ `player_skill_tree_progress` - Player's unlock state & XP
- ✅ `skill_tree_unlock_history` - Audit trail of unlocks
- ✅ `skill_tree_quest_requirements` - Optional quest-based unlocks

---

## Usage Examples

### Query: Get all unlocked skill levels for a player

```sql
SELECT 
    s.name AS skill_name,
    sl.level_number,
    sl.name AS level_name,
    pstp.experience,
    pstp.max_unlocked_level
FROM attributes.skill_levels sl
JOIN attributes.skills s ON sl.skill_id = s.id
JOIN attributes.player_skill_tree_progress pstp 
    ON pstp.skill_id = sl.skill_id AND pstp.player_id = 123
WHERE sl.level_number <= pstp.max_unlocked_level;
```

### Query: Get available upgrades for a player

```sql
SELECT 
    sl.skill_id,
    s.name AS skill_name,
    sl.level_number,
    sl.name AS level_name,
    sl.max_value as xp_required
FROM attributes.skill_levels sl
JOIN attributes.skills s ON sl.skill_id = s.id
LEFT JOIN attributes.player_skill_tree_progress pstp 
    ON pstp.skill_id = sl.skill_id AND pstp.player_id = 123
WHERE (pstp.current_level IS NULL OR pstp.max_unlocked_level < sl.level_number)
  AND sl.level_number = GREATEST(COALESCE(pstp.current_level, 0), 0) + 1;
```

### Query: Get skill tree statistics

```sql
SELECT * FROM attributes.get_skill_tree_stats(123);
-- Returns: total_skills, unlocked_levels, locked_levels, total_xp_earned, progress_percentage
```

---

## Migration Notes

### Step 1: Create Tables
Run all `CREATE TABLE` statements in order (dependencies matter).

### Step 2: Create Indexes
Run all `CREATE INDEX` statements for performance.

### Step 3: Create Views
Run all `CREATE VIEW` statements after tables exist.

### Step 4: Create Functions
Run all function creation statements.

### Step 5: Insert Sample Data (Optional)
Use the sample INSERT statements to populate initial data.

---

## Future Enhancements

- [ ] Add skill tree achievement system
- [ ] Implement skill respec functionality
- [ ] Add skill synergy bonuses (unlocking multiple related skills)
- [ ] Create skill tree mastery levels
- [ ] Add seasonal/special event skill trees
- [ ] Implement skill tree trading between players
- [ ] Add skill tree customization options

---

## License & Credits

This schema is designed for the Sybath RPG project and integrates with the existing database architecture. All functions are written in PostgreSQL PL/pgSQL language.
