---
name: rpg-sql-generator
description: >
  Generates production-ready PostgreSQL migration scripts for an RPG game database.
  Use when asked to add new features, tables, functions, or API endpoints to the RPG game.
  Always reads the live schema via MCP before writing any SQL.
---

# RPG SQL Generator Skill

## Purpose

Generate `.sql` migration scripts that add new functionality to the RPG game database.
Every script must be consistent with existing naming conventions, schema structure, and API patterns discovered live from the database via MCP.

---

## Step 1 — Always read the schema first

Before writing a single line of SQL, call the MCP tools to understand the existing structure:

```
get_schema                          # full overview — tables + API functions
get_tables(schema: "relevant")      # drill into specific schema columns
get_functions(api_type: "get_api")  # see existing player-context function signatures
get_all_functions(search: "topic")  # find internal helpers related to the feature
```

**Never assume** column names, data types, foreign key targets, or function signatures. Always verify from the live schema.

---

## Step 2 — Understand the database architecture

### Schemas and their purpose

| Schema | Contents |
|--------|----------|
| `attributes` | Abilities, skills, stat definitions, player progression tables |
| `auth` | Users, sessions, OAuth accounts |
| `buildings` | Building types and instances |
| `cities` | Cities and city tiles |
| `districts` | Districts within cities |
| `inventory` | Containers, inventory slots, item instances |
| `items` | Item catalog, item stats, item types |
| `knowledge` | Fog-of-war: `known_map_tiles`, `known_player_positions`, etc. |
| `players` | Player characters, stats, positions |
| `squad` | Player squads / parties |
| `tasks` | Async task queue — jobs scheduled by `action_api` functions |
| `world` | Maps, tiles, terrain types, regions, coordinates |
| `admin` | Map generation, player creation, admin procedures (NOT exposed via API) |
| `util` | Internal helpers like `raise_error()` (NOT exposed via API) |

### API function types

Every function exposed to the game client has a SQL comment declaring its type:

```sql
COMMENT ON FUNCTION schema.function_name IS 'automatic_get_api';
COMMENT ON FUNCTION schema.function_name IS 'get_api';
COMMENT ON FUNCTION schema.function_name IS 'action_api';
```

| Type | Purpose | Signature pattern |
|------|---------|-------------------|
| `automatic_get_api` | Dictionary / reference data. No player context needed. Always safe to cache. | `get_X()` and `get_X_by_key(p_id)` pairs |
| `get_api` | Player-context data. Respects fog-of-war via `knowledge.*` tables. Returns NULL fields for unknown data, never missing rows. | Always first param: `p_player_id integer` |
| `action_api` | Modifies game state. May queue async work in `tasks.tasks`. | Always returns `TABLE(status boolean, message text)` |

---

## Step 3 — SQL conventions to follow

Study these from the live schema and apply consistently:

### Naming
- All identifiers: `snake_case`
- Function parameters prefix: `p_` (e.g. `p_player_id`, `p_item_id`, `p_amount`)
- Primary keys: `id SERIAL PRIMARY KEY` or `id BIGSERIAL PRIMARY KEY`
- Foreign keys: `<table>_id` (e.g. `player_id`, `item_id`, `map_id`)
- Timestamps: `created_at TIMESTAMPTZ NOT NULL DEFAULT now()`
- Mutable tables also get: `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()`

### Tables
```sql
CREATE TABLE IF NOT EXISTS schema.table_name (
    id          SERIAL PRIMARY KEY,
    player_id   INTEGER NOT NULL REFERENCES players.players(id) ON DELETE CASCADE,
    -- ... other columns
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Indexes
Always add indexes for foreign keys and frequently queried columns:
```sql
CREATE INDEX IF NOT EXISTS idx_table_player_id ON schema.table_name(player_id);
```

### automatic_get_api functions (dictionary data)
Always create pairs — one for all rows, one for lookup by key:
```sql
CREATE OR REPLACE FUNCTION schema.get_item_types()
RETURNS TABLE(id integer, name text, description text)
LANGUAGE sql STABLE SECURITY DEFINER AS $$
    SELECT id, name, description FROM schema.item_types ORDER BY id;
$$;
COMMENT ON FUNCTION schema.get_item_types() IS 'automatic_get_api';

CREATE OR REPLACE FUNCTION schema.get_item_type_by_key(p_id integer)
RETURNS TABLE(id integer, name text, description text)
LANGUAGE sql STABLE SECURITY DEFINER AS $$
    SELECT id, name, description FROM schema.item_types WHERE id = p_id;
$$;
COMMENT ON FUNCTION schema.get_item_type_by_key(integer) IS 'automatic_get_api';
```

### get_api functions (player-context data)
```sql
CREATE OR REPLACE FUNCTION schema.get_player_something(p_player_id integer)
RETURNS TABLE(col1 type, col2 type)
LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
BEGIN
    -- Always check fog-of-war via knowledge.* tables when returning world data
    -- Return NULL fields (not missing rows) for data the player hasn't discovered
    RETURN QUERY
        SELECT t.col1, t.col2
        FROM schema.table t
        WHERE t.player_id = p_player_id;
END;
$$;
COMMENT ON FUNCTION schema.get_player_something(integer) IS 'get_api';
```

### action_api functions (game actions)
```sql
CREATE OR REPLACE FUNCTION schema.do_something(
    p_player_id integer,
    p_target_id integer
)
RETURNS TABLE(status boolean, message text)
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_something record;
BEGIN
    -- 1. Validate inputs
    IF p_target_id IS NULL THEN
        RETURN QUERY SELECT false, 'Target ID is required'::text;
        RETURN;
    END IF;

    -- 2. Business logic
    -- ...

    -- 3. Apply changes
    -- ...

    RETURN QUERY SELECT true, 'Success message'::text;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, SQLERRM::text;
END;
$$;
COMMENT ON FUNCTION schema.do_something(integer, integer) IS 'action_api';
```

### JSONB parameters for complex actions
When an action requires ordered steps (movement paths, batch operations), use JSONB arrays:
```sql
-- Example from do_player_movement:
-- p_path jsonb  →  '[{"order":1,"mapId":1,"x":5,"y":6,"moveCost":2,"totalMoveCost":2}]'
```

---

## Step 4 — Script structure

Every generated `.sql` file must follow this structure:

```sql
-- ============================================================
-- Migration: <short description>
-- Schema(s): <affected schemas>
-- Created: <date>
-- ============================================================

BEGIN;

-- ── Tables ──────────────────────────────────────────────────

-- ... CREATE TABLE IF NOT EXISTS ...
-- ... CREATE INDEX IF NOT EXISTS ...

-- ── Reference data (automatic_get_api) ───────────────────────

-- ... get_X() / get_X_by_key() function pairs ...
-- ... COMMENT ON FUNCTION ... IS 'automatic_get_api' ...

-- ── Player data (get_api) ─────────────────────────────────────

-- ... get_player_X() functions ...
-- ... COMMENT ON FUNCTION ... IS 'get_api' ...

-- ── Actions (action_api) ──────────────────────────────────────

-- ... do_X() functions ...
-- ... COMMENT ON FUNCTION ... IS 'action_api' ...

COMMIT;
```

---

## Step 5 — Output format

Always respond with:

1. **Design summary** — which tables, functions, and API type comments you're adding, and why
2. **Single SQL block** — the complete migration script wrapped in one ```sql ... ``` block
3. **Usage examples** — how to call the new functions from the game client

---

## Checklist before finalizing SQL

- [ ] Read live schema with MCP before writing SQL
- [ ] Every new table has `created_at` and `IF NOT EXISTS`
- [ ] Every FK column has a matching index
- [ ] `automatic_get_api`: paired `get_X()` + `get_X_by_key(p_id)` functions
- [ ] `get_api`: first param is always `p_player_id integer`
- [ ] `action_api`: always returns `TABLE(status boolean, message text)`, has `EXCEPTION WHEN OTHERS` block
- [ ] Every function has `COMMENT ON FUNCTION ... IS '<api_type>'`
- [ ] No `SELECT *` anywhere
- [ ] Schema prefix on every object (`schema.table`, `schema.function`)
- [ ] Entire script wrapped in `BEGIN; ... COMMIT;`
