---
name: rpg-game-design
description: >
  How to analyse and decompose RPG game feature requests into database-level components.
  Use this skill during Phase 2 of planning to ensure nothing is missed.
---

# RPG Game Design Skill

## Feature anatomy

Every RPG feature decomposes into the same building blocks. Work through each one.

---

### 1. Reference data (→ `automatic_get_api`)

Things that are defined once and rarely change. Players read these to populate dropdowns, show names, check limits.

Examples: item types, terrain types, building categories, skill trees, rank definitions, recipe lists.

**For each reference data set, create:**
- One dictionary table in the relevant schema
- `get_X()` — returns all rows
- `get_X_by_key(p_id)` — returns one row by primary key
- Both tagged `automatic_get_api`

**Ask yourself:** Does this feature introduce any new categories, types, or configuration that multiple rows of data will reference?

---

### 2. State tables (→ `get_api` reads)

The persistent state of the game world related to this feature. Usually one "main" table per feature, sometimes supporting tables.

Examples: player guild membership, inventory slots, quest progress, known recipes.

**For each state table:**
- Identify all columns and their types (check MCP for FK targets)
- Add `created_at`, `updated_at` if rows change over time
- Add `deleted_at` (soft delete) if history matters
- Define foreign keys to existing tables — always verify exact column names via MCP
- Define indexes for every FK column and every column used in WHERE clauses

**Ask yourself:** What data does the game need to persist? What does it need to look up quickly?

---

### 3. Player read functions (→ `get_api`)

What can a player see about this feature? Design one function per logical "view".

Rules:
- First parameter always `p_player_id integer`
- Returns NULL fields (not missing rows) for data the player hasn't discovered
- Check `knowledge.*` tables for fog-of-war constraints when returning world/position data
- Use `STABLE` if no side effects, `VOLATILE` if it logs access

**Ask yourself:**
- What does the player's own UI need to display?
- What can they see about other players? (check fog-of-war)
- What aggregate/summary data is useful? (e.g. total weight, slot count)

---

### 4. Player action functions (→ `action_api`)

What can a player DO in this feature? Design one function per atomic action.

Rules:
- Returns `TABLE(status boolean, message text)` — always
- First validate all inputs, return `(false, reason)` for every failure case
- List ALL failure cases explicitly in the spec
- Wrap everything in `BEGIN ... EXCEPTION WHEN OTHERS THEN RETURN QUERY SELECT false, SQLERRM`
- If the operation is slow or affects other players, queue a task in `tasks.tasks`

**Ask yourself:**
- Create / join / build / craft?
- Delete / leave / destroy / consume?
- Transfer / trade / move?
- What can go wrong? (at capacity, not enough resources, wrong state, not owner, cooldown)

---

### 5. Async tasks (→ `tasks.tasks`)

Some actions don't complete instantly — movement, exploration, crafting timers, scheduled events.

If an `action_api` function should queue work:
- Define the task type name (string key used in `tasks.tasks`)
- Define the JSONB payload structure
- Define what happens when the task completes

**Ask yourself:** Does this action take time? Does it trigger follow-up effects?

---

### 6. Fog-of-war updates (→ `knowledge.*`)

If the feature reveals world information to the player, a corresponding row must be inserted into the appropriate `knowledge.*` table.

**Ask yourself:** Does this feature let a player discover a location, another player, a building, or a resource? If yes, add a `knowledge.*` insert.

---

## Common feature patterns

### Pattern: Membership system (guilds, squads, factions)

```
Tables:
  schema.entities          — the guild/squad/faction itself
  schema.memberships        — player ↔ entity join table with rank/role

Reference data:
  schema.ranks              — rank definitions
  get_ranks() / get_rank_by_key(p_id)   [automatic_get_api]

Player reads:
  get_player_membership(p_player_id)     [get_api]  — own guild info
  get_entity_members(p_player_id, p_entity_id)  [get_api]  — who's in it

Actions:
  do_create_entity(p_player_id, p_name)  [action_api]
  do_join_entity(p_player_id, p_entity_id)   [action_api]
  do_leave_entity(p_player_id)           [action_api]
  do_kick_member(p_player_id, p_target_player_id)  [action_api]
  do_promote_member(p_player_id, p_target_player_id, p_rank_id)  [action_api]
```

---

### Pattern: Inventory / container system

```
Tables:
  schema.containers         — a container (backpack, chest, shop)
  schema.slots              — item instance in a slot within a container

Reference data:
  schema.container_types    — type definitions (backpack, chest, …)
  get_container_types() / get_container_type_by_key(p_id)  [automatic_get_api]

Player reads:
  get_player_containers(p_player_id)         [get_api]
  get_container_contents(p_player_id, p_container_id)  [get_api]

Actions:
  do_add_item(p_player_id, p_container_id, p_item_id, p_amount)   [action_api]
  do_remove_item(p_player_id, p_container_id, p_slot_id, p_amount) [action_api]
  do_move_item(p_player_id, p_from_slot_id, p_to_container_id)     [action_api]
```

---

### Pattern: Resource / crafting system

```
Tables:
  schema.recipes            — recipe definitions
  schema.recipe_ingredients — ingredient ↔ recipe join
  schema.craft_queue        — in-progress crafts (if async)

Reference data:
  get_recipes() / get_recipe_by_key(p_id)         [automatic_get_api]
  get_recipe_ingredients(p_recipe_id)             [automatic_get_api]

Player reads:
  get_player_known_recipes(p_player_id)           [get_api]

Actions:
  do_learn_recipe(p_player_id, p_recipe_id)       [action_api]
  do_craft_item(p_player_id, p_recipe_id)         [action_api]  — queues task if slow
```

---

### Pattern: Economy / trading

```
Tables:
  schema.listings           — active trade offers
  schema.transactions       — completed trade history

Player reads:
  get_market_listings(p_player_id)                [get_api]
  get_player_transactions(p_player_id)            [get_api]

Actions:
  do_create_listing(p_player_id, p_item_id, p_amount, p_price)  [action_api]
  do_buy_listing(p_player_id, p_listing_id, p_amount)            [action_api]
  do_cancel_listing(p_player_id, p_listing_id)                   [action_api]
```

---

## Failure case checklist

For every `action_api` function, explicitly list ALL cases that return `(false, reason)`:

- [ ] Player does not exist / is not active
- [ ] Target entity does not exist
- [ ] Player lacks required permissions / rank
- [ ] Player is already in the required state (already member, already has item)
- [ ] Player is not in the required state (not a member, doesn't own item)
- [ ] Capacity exceeded (inventory full, guild at max members)
- [ ] Insufficient resources (not enough gold, materials, energy)
- [ ] Cooldown active (action was done too recently)
- [ ] Target player not found or blocked
- [ ] Concurrent modification (someone else acted first)
