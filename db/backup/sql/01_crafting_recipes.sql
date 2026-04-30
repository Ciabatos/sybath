-- ============================================
-- CRAFTING RECIPES TABLE FOR RPG GAME
-- ============================================
-- File: 01_crafting_recipes.sql
-- Purpose: Define recipe table for item crafting system
-- Author: Game Systems Designer
-- Date: 2026-03-24

-- ============================================
-- DROP EXISTING TABLE (if exists)
-- ============================================

DROP TABLE IF EXISTS items.recipe CASCADE;

-- ============================================
-- CREATE RECIPES TABLE
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
    
    -- Crafting Requirements (materials needed)
    crafting_materials jsonb NOT NULL DEFAULT '[]'::jsonb,
    
    -- Skill/Ability Requirements
    required_skills jsonb DEFAULT '[]'::jsonb,
    
    -- Crafting Stats (optional: time to craft, success chance modifiers, etc.)
    crafting_stats jsonb DEFAULT '{}'::jsonb,
    
    -- Metadata
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);

-- ============================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_recipe_result_item ON items.recipe(result_item_id);
CREATE INDEX idx_recipe_name ON items.recipe(name);
CREATE INDEX idx_recipe_active ON items.recipe(is_active) WHERE is_active = true;

-- ============================================
-- ADD COMMENTS FOR DOCUMENTATION
-- ============================================

COMMENT ON TABLE items.recipe IS 'Stores craftable recipes for items in the game. Each recipe defines materials, skills, and stats needed to create an item.';
COMMENT ON COLUMN items.recipe.id IS 'Unique identifier for the recipe';
COMMENT ON COLUMN items.recipe.name IS 'Name of the crafting recipe (e.g., "Craft Spear of Wood and Stone")';
COMMENT ON COLUMN items.recipe.description IS 'Detailed description explaining what the recipe does and how to use it';
COMMENT ON COLUMN items.recipe.image IS 'Icon/image displayed in the crafting UI for this recipe';
COMMENT ON COLUMN items.recipe.result_item_id IS 'Foreign key referencing the item that will be created when this recipe is used';
COMMENT ON COLUMN items.recipe.crafting_materials IS 'JSON array of materials needed: [{"item_id": X, "quantity": Y}, ...]';
COMMENT ON COLUMN items.recipe.required_skills IS 'JSON array of skill requirements: [{"skill_id": X, "min_value": Y}, ...]';
COMMENT ON COLUMN items.recipe.crafting_stats IS 'JSON object with crafting parameters like time, success chance, XP reward';
COMMENT ON COLUMN items.recipe.is_active IS 'Whether this recipe is currently available for players to craft';

-- ============================================
-- INSERT MATERIAL ITEMS (Raw Materials)
-- ============================================

INSERT INTO items.items (id, name, description, image, item_type_id) VALUES
(501, 'Wooden Shaft', 
 'A sturdy wooden shaft suitable for weapon crafting.', 
 'wood_shaft.png', 3), -- Type 3 = "Raw Material"
(502, 'Stone Tip', 
 'A sharpened stone tip for spear heads and weapons.', 
 'stone_tip.png', 3);

-- ============================================
-- INSERT CRAFTED ITEM: SPEAR OF WOOD AND STONE
-- ============================================

INSERT INTO items.items (id, name, description, image, item_type_id) VALUES
(1001, 'Spear of Wood and Stone', 
 'A sturdy spear crafted from a wooden shaft reinforced with stone tips. 
  Effective for both thrusting attacks and light striking.', 
 'spear_wood_stone.png', 2); -- Type 2 = "Weapon"

-- ============================================
-- INSERT CRAFTING RECIPES
-- ============================================

INSERT INTO items.recipe (id, name, description, result_item_id, crafting_materials, required_skills, crafting_stats) VALUES
(1001, 
 'Craft Spear of Wood and Stone',
 'Combine a wooden shaft with stone tips to create a sturdy spear. 
  Requires basic woodworking and stonecrafting skills.',
 1001,
 -- Materials needed for crafting (JSON format: [{"item_id": X, "quantity": Y}])
 '[{"item_id": 501, "quantity": 2}, {"item_id": 502, "quantity": 1}]',
 -- Required skills (JSON format: [{"skill_id": X, "min_value": Y}])
 '[{"skill_id": 3, "min_value": 5}, {"skill_id": 7, "min_value": 3}]',
 -- Crafting stats (JSON format: {"craft_time_seconds": 60, "success_chance_modifier": 1.0})
 '{"craft_time_seconds": 60, "success_chance_modifier": 1.0}'::jsonb
);

-- ============================================
-- INSERT ADDITIONAL SKILLS (if not exist)
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
-- INSERT ADDITIONAL RECIPES FOR EXAMPLES
-- ============================================

-- Recipe 2: Stone Axe
INSERT INTO items.items (id, name, description, image, item_type_id) VALUES
(1002, 'Stone Axe', 
 'A heavy axe made entirely of stone. Good for chopping wood and breaking rocks.', 
 'stone_axe.png', 2);

INSERT INTO items.recipe (id, name, description, result_item_id, crafting_materials, required_skills, crafting_stats) VALUES
(1002, 
 'Craft Stone Axe',
 'Create a heavy stone axe by combining multiple stone tips into an axe head.',
 1002,
 '[{"item_id": 502, "quantity": 3}]',
 '[{"skill_id": 7, "min_value": 4}]',
 '{"craft_time_seconds": 90, "success_chance_modifier": 0.8}'::jsonb
);

-- Recipe 3: Wooden Shield
INSERT INTO items.items (id, name, description, image, item_type_id) VALUES
(1003, 'Wooden Shield', 
 'A simple wooden shield for basic protection in combat.', 
 'wooden_shield.png', 2);

INSERT INTO items.recipe (id, name, description, result_item_id, crafting_materials, required_skills, crafting_stats) VALUES
(1003, 
 'Craft Wooden Shield',
 'Create a protective wooden shield from multiple wooden shafts bound together.',
 1003,
 '[{"item_id": 501, "quantity": 4}]',
 '[{"skill_id": 3, "min_value": 6}]',
 '{"craft_time_seconds": 120, "success_chance_modifier": 0.9}'::jsonb
);

-- Recipe 4: Stone Spear (Advanced)
INSERT INTO items.items (id, name, description, image, item_type_id) VALUES
(1004, 'Stone Spear', 
 'An advanced spear made entirely of stone. Heavier but more durable than wooden versions.', 
 'stone_spear.png', 2);

INSERT INTO items.recipe (id, name, description, result_item_id, crafting_materials, required_skills, crafting_stats) VALUES
(1004, 
 'Craft Stone Spear',
 'Create a heavy stone spear requiring advanced stonecrafting skills.',
 1004,
 '[{"item_id": 502, "quantity": 3}]',
 '[{"skill_id": 7, "min_value": 8}]',
 '{"craft_time_seconds": 180, "success_chance_modifier": 0.6}'::jsonb
);

-- ============================================
-- VERIFY INSERTION
-- ============================================

SELECT 'Recipes table created successfully!' AS status;
SELECT COUNT(*) as total_recipes FROM items.recipe WHERE is_active = true;
SELECT name, result_item_id, crafting_materials 
FROM items.recipe 
WHERE is_active = true 
ORDER BY id;

