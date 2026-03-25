-- ============================================
-- CRAFTING RECIPES TABLE (NORMALIZED VERSION)
-- ============================================
-- File: 02_crafting_recipes_normalized.sql
-- Purpose: Define recipe table with normalized relational structure
-- Author: Game Systems Designer
-- Date: 2026-03-24

-- ============================================
-- DROP EXISTING TABLES (if exists)
-- ============================================

DROP TABLE IF EXISTS items.recipe_materials CASCADE;
DROP TABLE IF EXISTS items.recipe_skills CASCADE;
DROP TABLE IF EXISTS items.recipe_stats CASCADE;
DROP TABLE IF EXISTS items.recipe CASCADE;

-- ============================================
-- STEP 1: CREATE MAIN RECIPES TABLE
-- ============================================

CREATE TABLE items.recipe (
    -- Primary Key
    id integer PRIMARY KEY,
    
    -- Recipe Identification
    name character varying NOT NULL,
    description text,
    image character varying DEFAULT 'default.png',
    
    -- Reference to the crafted item
    result_item_id integer NOT NULL REFERENCES items.items(id) ON DELETE CASCADE,
    
    -- Metadata
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);

-- ============================================
-- STEP 2: CREATE RECIPE MATERIALS TABLE (Many-to-Many)
-- ============================================

CREATE TABLE items.recipe_materials (
    -- Composite Primary Key
    recipe_id integer NOT NULL REFERENCES items.recipe(id) ON DELETE CASCADE,
    material_item_id integer NOT NULL REFERENCES items.items(id) ON DELETE RESTRICT,
    
    -- Quantity of each material needed
    quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
    
    -- Optional: Modifier for this specific recipe (e.g., "double" or "half")
    modifier character varying DEFAULT 'normal',
    
    -- Primary Key constraint on composite key
    PRIMARY KEY (recipe_id, material_item_id)
);

-- ============================================
-- STEP 3: CREATE RECIPE SKILLS TABLE (Many-to-Many)
-- ============================================

CREATE TABLE items.recipe_skills (
    -- Composite Primary Key
    recipe_id integer NOT NULL REFERENCES items.recipe(id) ON DELETE CASCADE,
    skill_id integer NOT NULL REFERENCES attributes.skills(id) ON DELETE RESTRICT,
    
    -- Minimum skill level required
    min_level integer NOT NULL DEFAULT 1 CHECK (min_level >= 0),
    
    -- Primary Key constraint on composite key
    PRIMARY KEY (recipe_id, skill_id)
);

-- ============================================
-- STEP 4: CREATE RECIPE STATS TABLE (Optional Extended Stats)
-- ============================================

CREATE TABLE items.recipe_stats (
    -- Primary Key
    recipe_id integer NOT NULL REFERENCES items.recipe(id) ON DELETE CASCADE,
    
    -- Crafting parameters as individual columns for better querying
    craft_time_seconds integer DEFAULT 60 CHECK (craft_time_seconds > 0),
    success_chance_modifier numeric(3,2) DEFAULT '1.00' CHECK (success_chance_modifier > 0),
    experience_reward integer DEFAULT 0 CHECK (experience_reward >= 0),
    gold_cost integer DEFAULT 0 CHECK (gold_cost >= 0),
    
    -- Primary Key constraint
    PRIMARY KEY (recipe_id)
);

-- ============================================
-- STEP 5: CREATE INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_recipe_result_item ON items.recipe(result_item_id);
CREATE INDEX idx_recipe_name ON items.recipe(name);
CREATE INDEX idx_recipe_active ON items.recipe(is_active) WHERE is_active = true;

-- Indexes for recipe_materials (find recipes by material, find materials by recipe)
CREATE INDEX idx_recipe_materials_recipe ON items.recipe_materials(recipe_id);
CREATE INDEX idx_recipe_materials_item ON items.recipe_materials(material_item_id);

-- Indexes for recipe_skills (find recipes by skill, find skills by recipe)
CREATE INDEX idx_recipe_skills_recipe ON items.recipe_skills(recipe_id);
CREATE INDEX idx_recipe_skills_skill ON items.recipe_skills(skill_id);

-- ============================================
-- STEP 6: ADD COMMENTS FOR DOCUMENTATION
-- ============================================

COMMENT ON TABLE items.recipe IS 'Main table storing craftable recipes. Each recipe defines what item is created.';
COMMENT ON COLUMN items.recipe.id IS 'Unique identifier for the recipe';
COMMENT ON COLUMN items.recipe.name IS 'Name of the crafting recipe (e.g., "Craft Spear of Wood and Stone")';
COMMENT ON COLUMN items.recipe.description IS 'Detailed description explaining what the recipe does and how to use it';
COMMENT ON COLUMN items.recipe.image IS 'Icon/image displayed in the crafting UI for this recipe';
COMMENT ON COLUMN items.recipe.result_item_id IS 'Foreign key referencing the item that will be created when this recipe is used';

COMMENT ON TABLE items.recipe_materials IS 'Stores materials required for each recipe. One recipe can use multiple materials.';
COMMENT ON COLUMN items.recipe_materials.recipe_id IS 'Reference to the parent recipe';
COMMENT ON COLUMN items.recipe_materials.material_item_id IS 'Foreign key referencing the material item needed';
COMMENT ON COLUMN items.recipe_materials.quantity IS 'Number of this material required for the recipe';

COMMENT ON TABLE items.recipe_skills IS 'Stores skill requirements for each recipe. One recipe can require multiple skills.';
COMMENT ON COLUMN items.recipe_skills.recipe_id IS 'Reference to the parent recipe';
COMMENT ON COLUMN items.recipe_skills.skill_id IS 'Foreign key referencing the required skill';
COMMENT ON COLUMN items.recipe_skills.min_level IS 'Minimum level of this skill required to craft';

COMMENT ON TABLE items.recipe_stats IS 'Stores optional crafting parameters like time, success chance, rewards.';
COMMENT ON COLUMN items.recipe_stats.craft_time_seconds IS 'Time in seconds required to complete the craft';
COMMENT ON COLUMN items.recipe_stats.success_chance_modifier IS 'Multiplier for base success chance (e.g., 1.0 = normal, 0.8 = harder)';
COMMENT ON COLUMN items.recipe_stats.experience_reward IS 'XP awarded on successful craft';

-- ============================================
-- STEP 7: INSERT MATERIAL ITEMS (Raw Materials)
-- ============================================

INSERT INTO items.items (id, name, description, image, item_type_id) VALUES
(501, 'Wooden Shaft', 
 'A sturdy wooden shaft suitable for weapon crafting.', 
 'wood_shaft.png', 3), -- Type 3 = "Raw Material"
(502, 'Stone Tip', 
 'A sharpened stone tip for spear heads and weapons.', 
 'stone_tip.png', 3)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- STEP 8: INSERT CRAFTED ITEM: SPEAR OF WOOD AND STONE
-- ============================================

INSERT INTO items.items (id, name, description, image, item_type_id) VALUES
(1001, 'Spear of Wood and Stone', 
 'A sturdy spear crafted from a wooden shaft reinforced with stone tips. 
  Effective for both thrusting attacks and light striking.', 
 'spear_wood_stone.png', 2)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- STEP 9: INSERT MAIN RECIPE RECORDS
-- ============================================

INSERT INTO items.recipe (id, name, description, result_item_id, is_active) VALUES
(1001, 'Craft Spear of Wood and Stone',
 'Combine a wooden shaft with stone tips to create a sturdy spear. 
  Requires basic woodworking and stonecrafting skills.',
 1001, true);

INSERT INTO items.recipe (id, name, description, result_item_id, is_active) VALUES
(1002, 'Craft Stone Axe',
 'Create a heavy stone axe by combining multiple stone tips into an axe head.',
 1003, true); -- Note: We'll create the actual item below

INSERT INTO items.recipe (id, name, description, result_item_id, is_active) VALUES
(1003, 'Craft Wooden Shield',
 'Create a protective wooden shield from multiple wooden shafts bound together.',
 1004, true); -- Note: We'll create the actual item below

INSERT INTO items.recipe (id, name, description, result_item_id, is_active) VALUES
(1004, 'Craft Stone Spear',
 'Create a heavy stone spear requiring advanced stonecrafting skills.',
 1005, true); -- Note: We'll create the actual item below

-- ============================================
-- STEP 10: INSERT RECIPE MATERIALS (Link recipes to materials)
-- ============================================

-- Recipe 1001: Spear of Wood and Stone needs 2 Wooden Shafts + 1 Stone Tip
INSERT INTO items.recipe_materials (recipe_id, material_item_id, quantity, modifier) VALUES
(1001, 501, 2, 'normal'),   -- 2 Wooden Shafts
(1001, 502, 1, 'normal');   -- 1 Stone Tip

-- Recipe 1002: Stone Axe needs 3 Stone Tips
INSERT INTO items.recipe_materials (recipe_id, material_item_id, quantity, modifier) VALUES
(1002, 502, 3, 'normal');   -- 3 Stone Tips

-- Recipe 1003: Wooden Shield needs 4 Wooden Shafts
INSERT INTO items.recipe_materials (recipe_id, material_item_id, quantity, modifier) VALUES
(1003, 501, 4, 'normal');   -- 4 Wooden Shafts

-- Recipe 1004: Stone Spear needs 3 Stone Tips
INSERT INTO items.recipe_materials (recipe_id, material_item_id, quantity, modifier) VALUES
(1004, 502, 3, 'normal');   -- 3 Stone Tips

-- ============================================
-- STEP 11: INSERT ADDITIONAL SKILLS (if not exist)
-- ============================================

INSERT INTO attributes.skills (id, name, description, image) VALUES
(3, 'Woodworking', 
 'Skill in crafting wooden items and tools. Higher levels allow more complex constructions.', 
 'woodworking.png')
ON CONFLICT (id) DO NOTHING;

INSERT INTO attributes.skills (id, name, description, image) VALUES
(7, 'Stonecrafting', 
 'Skill in working with stone materials for weapons and armor. Essential for metal-free crafting.', 
 'stonecrafting.png')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- STEP 12: INSERT RECIPE SKILLS (Link recipes to required skills)
-- ============================================

-- Recipe 1001: Spear requires Woodworking Lv5+ AND Stonecrafting Lv3+
INSERT INTO items.recipe_skills (recipe_id, skill_id, min_level) VALUES
(1001, 3, 5),   -- Woodworking level 5 required
(1001, 7, 3);   -- Stonecrafting level 3 required

-- Recipe 1002: Stone Axe requires Stonecrafting Lv4+
INSERT INTO items.recipe_skills (recipe_id, skill_id, min_level) VALUES
(1002, 7, 4);   -- Stonecrafting level 4 required

-- Recipe 1003: Wooden Shield requires Woodworking Lv6+
INSERT INTO items.recipe_skills (recipe_id, skill_id, min_level) VALUES
(1003, 3, 6);   -- Woodworking level 6 required

-- Recipe 1004: Stone Spear requires Stonecrafting Lv8+
INSERT INTO items.recipe_skills (recipe_id, skill_id, min_level) VALUES
(1004, 7, 8);   -- Stonecrafting level 8 required

-- ============================================
-- STEP 13: INSERT CRAFTED ITEMS (if not exist)
-- ============================================

INSERT INTO items.items (id, name, description, image, item_type_id) VALUES
(1002, 'Stone Axe', 
 'A heavy axe made entirely of stone. Good for chopping wood and breaking rocks.', 
 'stone_axe.png', 2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO items.items (id, name, description, image, item_type_id) VALUES
(1003, 'Wooden Shield', 
 'A simple wooden shield for basic protection in combat.', 
 'wooden_shield.png', 2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO items.items (id, name, description, image, item_type_id) VALUES
(1004, 'Stone Spear', 
 'An advanced spear made entirely of stone. Heavier but more durable than wooden versions.', 
 'stone_spear.png', 2)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- STEP 14: INSERT RECIPE STATS (Optional Extended Stats)
-- ============================================

INSERT INTO items.recipe_stats (recipe_id, craft_time_seconds, success_chance_modifier, experience_reward) VALUES
(1001, 60, '1.00', 10),   -- Spear: 60 seconds, normal difficulty, 10 XP
(1002, 90, '0.80', 15),   -- Stone Axe: 90 seconds, harder, 15 XP
(1003, 120, '0.90', 12),  -- Wooden Shield: 120 seconds, easier, 12 XP
(1004, 180, '0.60', 20);  -- Stone Spear: 180 seconds, very hard, 20 XP

-- ============================================
-- STEP 15: VERIFY INSERTION
-- ============================================

SELECT 'Normalized recipes table created successfully!' AS status;

-- Show all active recipes
SELECT 
    r.id,
    r.name,
    r.result_item_id,
    (SELECT COUNT(*) FROM items.recipe_materials WHERE recipe_id = r.id) as materials_count,
    (SELECT COUNT(*) FROM items.recipe_skills WHERE recipe_id = r.id) as skills_required
FROM items.recipe r
WHERE r.is_active = true
ORDER BY r.id;

-- Show materials for a specific recipe (example: Spear)
SELECT 
    rm.recipe_id,
    i.name AS material_name,
    rm.quantity,
    rm.modifier
FROM items.recipe_materials rm
JOIN items i ON rm.material_item_id = i.id
WHERE rm.recipe_id = 1001;

-- Show skills for a specific recipe (example: Spear)
SELECT 
    rs.recipe_id,
    s.name AS skill_name,
    rs.min_level
FROM items.recipe_skills rs
JOIN attributes.skills s ON rs.skill_id = s.id
WHERE rs.recipe_id = 1001;

