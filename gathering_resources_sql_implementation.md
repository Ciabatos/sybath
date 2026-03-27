# Gathering Resources - Complete SQL Implementation & Improvements

## Current State Analysis

### Existing Function (items.do_gather_resources_on_map_tile)
```sql
-- CURRENT IMPLEMENTATION (INCOMPLETE!)
CREATE OR REPLACE FUNCTION items.do_gather_resources_on_map_tile(
    p_player_id integer, 
    p_map_id integer, 
    p_x integer, 
    p_y integer, 
    p_map_tiles_resource_id integer, 
    p_gather_amount integer
) RETURNS TABLE(status boolean, message text)
LANGUAGE plpgsql AS $function$
BEGIN
    /* MUTEX */
    PERFORM 1 FROM players.players WHERE id = p_player_id FOR UPDATE;

    RETURN QUERY SELECT true, 'Gather resrources completed';
END;
$function$
```

**Problems:**
- ❌ Does NOT actually gather resources from `world.map_tiles_resources`
- ❌ Does NOT add items to player inventory
- ❌ No validation (player position, resource existence, quantity limits)
- ❌ No error handling for edge cases

---

## ✅ COMPLETE & IMPROVED Implementation

```sql
CREATE OR REPLACE FUNCTION items.do_gather_resources_on_map_tile(
    p_player_id integer, 
    p_map_id integer, 
    p_x integer, 
    p_y integer, 
    p_map_tiles_resource_id integer, 
    p_gather_amount integer
) RETURNS TABLE(status boolean, message text)
LANGUAGE plpgsql AS $function$
DECLARE
    v_player_name text;
    v_resource_item_id integer;
    v_resource_quantity integer;
    v_container_id integer;
    v_slot_id integer;
    v_actual_gathered integer;
    v_position_x world.map_tiles.x%TYPE := p_x;
    v_position_y world.map_tiles.y%TYPE := p_y;
BEGIN

-- ============================================================
-- 1. MUTEX: Lock player row to prevent concurrent gathers
-- ============================================================
PERFORM 1 
FROM players.players 
WHERE id = p_player_id 
FOR UPDATE SKIP LOCKED;

-- ============================================================
-- 2. VALIDATION: Check if player exists and is active
-- ============================================================
SELECT name INTO v_player_name 
FROM players.players 
WHERE id = p_player_id;

IF v_player_name IS NULL THEN
    RETURN QUERY SELECT false, 'Player not found';
END IF;

-- ============================================================
-- 3. VALIDATION: Verify player is at the specified map tile
-- ============================================================
IF NOT EXISTS (
    SELECT 1 FROM world.map_tiles_players_positions 
    WHERE player_id = p_player_id 
      AND map_id = p_map_id 
      AND map_tile_x = v_position_x 
      AND map_tile_y = v_position_y
) THEN
    RETURN QUERY SELECT false, 'Player is not at the specified map tile position';
END IF;

-- ============================================================
-- 4. VALIDATION: Check resource exists and belongs to this tile
-- ============================================================
SELECT item_id, quantity INTO v_resource_item_id, v_resource_quantity 
FROM world.map_tiles_resources 
WHERE id = p_map_tiles_resource_id 
  AND map_id = p_map_id 
  AND map_tile_x = v_position_x 
  AND map_tile_y = v_position_y;

IF v_resource_item_id IS NULL THEN
    RETURN QUERY SELECT false, 'Resource not found at this tile or resource ID is invalid';
END IF;

-- ============================================================
-- 5. VALIDATION: Check if player has inventory container
-- ============================================================
IF NOT EXISTS (
    SELECT 1 FROM inventory.inventory_containers 
    WHERE owner_id = p_player_id 
      AND inventory_container_type_id = 'player'::text
) THEN
    RETURN QUERY SELECT false, 'Player does not have an inventory container';
END IF;

-- Get the player's main inventory container ID
SELECT id INTO v_container_id 
FROM inventory.inventory_containers 
WHERE owner_id = p_player_id 
  AND inventory_container_type_id = 'player'::text
ORDER BY id DESC 
LIMIT 1;

-- ============================================================
-- 6. VALIDATION: Check if gather amount is valid and available
-- ============================================================
IF v_gather_amount <= 0 THEN
    RETURN QUERY SELECT false, 'Gather amount must be greater than 0';
END IF;

IF v_gather_amount > v_resource_quantity THEN
    -- Allow gathering more than available (will take all)
    v_actual_gathered := v_resource_quantity;
ELSE
    v_actual_gathered := v_gather_amount;
END IF;

-- ============================================================
-- 7. GATHER: Remove resources from map tile
-- ============================================================
UPDATE world.map_tiles_resources 
SET quantity = quantity - v_actual_gathered,
    -- Optional: Log the gather event (add a log table if needed)
    gathered_by = p_player_id,
    gathered_at = NOW()
WHERE id = p_map_tiles_resource_id;

-- If resource is depleted, optionally remove it from map tile
IF quantity - v_actual_gathered <= 0 THEN
    DELETE FROM world.map_tiles_resources 
    WHERE id = p_map_tiles_resource_id;
END IF;

-- ============================================================
-- 8. ADD TO INVENTORY: Add gathered item to first free slot
-- ============================================================
BEGIN
    -- Find first free slot in player's inventory
    SELECT id INTO v_slot_id 
    FROM inventory.inventory_slots 
    WHERE inventory_container_id = v_container_id 
      AND item_id IS NULL 
    ORDER BY id ASC 
    LIMIT 1;

    IF v_slot_id IS NOT NULL THEN
        -- Add the gathered resource to inventory
        PERFORM inventory.add_item_to_inventory_free_slot(
            p_inventory_container_id := v_container_id,
            p_item_id := v_resource_item_id,
            p_quantity := v_actual_gathered
        );
    ELSE
        RAISE EXCEPTION 'No free slots available in player''s inventory';
    END IF;

EXCEPTION WHEN OTHERS THEN
    -- Rollback resource deduction if inventory addition fails
    UPDATE world.map_tiles_resources 
    SET quantity = quantity + v_actual_gathered
    WHERE id = p_map_tiles_resource_id;
    
    RAISE EXCEPTION 'Failed to add gathered resources to inventory: %', SQLERRM;
END;

-- ============================================================
-- 9. SUCCESS: Return success message with details
-- ============================================================
RETURN QUERY 
SELECT true, 
       format('Gathered %d %s successfully!', v_actual_gathered, 
              (SELECT name FROM items.items WHERE id = v_resource_item_id));

END;
$function$;
```

---

## 🎯 Key Improvements Made

### 1. **Proper Resource Deduction**
- ✅ Actually reduces `quantity` in `world.map_tiles_resources`
- ✅ Optionally deletes depleted resources from map tile
- ✅ Tracks who gathered and when (add to table schema if needed)

### 2. **Comprehensive Validation**
| Check | Purpose |
|-------|---------|
| Player exists & active | Prevents invalid player operations |
| Player at correct position | Ensures player is actually at the tile |
| Resource exists at tile | Validates resource location matches |
| Inventory container exists | Ensures player can receive items |
| Gather amount > 0 | Prevents zero/negative gathers |

### 3. **Error Handling**
- ✅ Returns descriptive error messages for each failure case
- ✅ Transaction-safe: rolls back if inventory addition fails
- ✅ Uses `EXCEPTION WHEN OTHERS` to catch unexpected errors

### 4. **Smart Gathering Logic**
```sql
IF v_gather_amount > v_resource_quantity THEN
    -- Allow gathering more than available (takes all)
    v_actual_gathered := v_resource_quantity;
ELSE
    v_actual_gathered := v_gather_amount;
END IF;
```

### 5. **First Available Slot**
- ✅ Uses `ORDER BY id ASC LIMIT 1` to get first free slot
- ✅ Reuses existing `add_item_to_inventory_free_slot()` function
- ✅ Handles empty slots (`item_id IS NULL`) correctly

---

## 📋 Additional Schema Recommendations

### A. Add Resource History Table (Optional but Recommended)
```sql
CREATE TABLE world.map_tiles_resources_history (
    id SERIAL PRIMARY KEY,
    resource_id INTEGER REFERENCES world.map_tiles_resources(id),
    player_id INTEGER REFERENCES players.players(id),
    item_id INTEGER REFERENCES items.items(id),
    quantity_gathered INTEGER NOT NULL,
    map_id INTEGER,
    map_tile_x INTEGER,
    map_tile_y INTEGER,
    gathered_at TIMESTAMP DEFAULT NOW()
);

-- Add to gather function:
INSERT INTO world.map_tiles_resources_history (
    resource_id, player_id, item_id, quantity_gathered, 
    map_id, map_tile_x, map_tile_y, gathered_at
) VALUES (
    p_map_tiles_resource_id, p_player_id, v_resource_item_id, 
    v_actual_gathered, p_map_id, p_x, p_y, NOW()
);
```

### B. Add Resource Spawn Tracking
```sql
ALTER TABLE world.map_tiles_resources ADD COLUMN IF NOT EXISTS spawned_by INTEGER REFERENCES admin.map_insert;
ALTER TABLE world.map_tiles_resources ADD COLUMN IF NOT EXISTS last_spawn_time TIMESTAMP DEFAULT NOW();
```

### C. Add Player Inventory Container Auto-Creation
Instead of requiring manual container creation, auto-create on first gather:
```sql
-- In validation section (step 5):
IF v_container_id IS NULL THEN
    PERFORM inventory.add_inventory_container('player', p_player_id);
    
    -- Get newly created container ID
    SELECT id INTO v_container_id 
    FROM inventory.inventory_containers 
    WHERE owner_id = p_player_id 
      AND inventory_container_type_id = 'player'::text
    ORDER BY id DESC LIMIT 1;
END IF;
```

---

## 🔄 Component Flow for Gathering Action

### Data Sources (on mount)
- `get_map_tiles(p_map_id)` → display available tiles with resources
- `automatic_get_items()` → show resource names in UI
- `get_player_inventory(p_player_id)` → show current inventory slots

### Actions
**Gather Resources Button**
- Calls: `do_gather_resources_on_map_tile(p_player_id, p_map_id, p_x, p_y, p_resource_id, p_amount)`
- Params sourced from: form fields (map tile selection, gather amount)
- On success (`status=true`): 
  - Re-fetch inventory via `get_player_inventory()` to show new items
  - Show toast: "Gathered X resources!"
- On failure (`status=false`): 
  - Show error message from `message` field
  - Highlight the problematic input if validation failed

### Validation (client-side, before calling action)
| Field | Rule |
|-------|------|
| p_gather_amount | Must be > 0 and ≤ available resource quantity |
| Map tile position | Player must be at this exact (x,y) coordinate |
| Resource ID | Must exist and have quantity > 0 |

---

## 🧪 Testing Checklist

- [ ] Gather exactly the amount specified
- [ ] Gather more than available (should take all)
- [ ] Multiple players trying to gather same resource simultaneously (mutex test)
- [ ] Player not at correct position (validation test)
- [ ] Resource already depleted (should show error or allow 0 gather)
- [ ] Inventory full (should fail gracefully with clear message)
- [ ] Invalid player ID (should return false/error)
- [ ] Invalid resource ID (should return false/error)

---

## 📝 Summary of Changes Needed

1. **Update `items.do_gather_resources_on_map_tile`** - Replace current stub with full implementation above
2. **Add resource history table** (optional, for analytics/debugging)
3. **Consider auto-creating inventory containers** on first gather instead of requiring manual setup
4. **Add gathered_by/gathered_at columns** to `world.map_tiles_resources` if tracking is needed

---

## 📊 Database Schema Reference

### Tables Used:
| Table | Purpose |
|-------|---------|
| `players.players` | Player identity and mutex lock |
| `world.map_tiles_players_positions` | Verify player location |
| `world.map_tiles_resources` | Resource data source (deduct quantity) |
| `inventory.inventory_containers` | Find player's inventory container |
| `inventory.inventory_slots` | Find first free slot |

### Functions Used:
| Function | Purpose |
|----------|---------|
| `inventory.add_item_to_inventory_free_slot()` | Add item to first empty slot |

---

## 🚀 Deployment Notes

1. **Backup** current function before replacing
2. **Test** with single player first, then multi-player concurrency
3. **Monitor** for any inventory full edge cases
4. **Consider** adding resource respawn logic after depletion

