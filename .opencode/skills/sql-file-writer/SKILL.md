---
name: sql-file-writer
description: >
  Rules for naming, structuring, and writing .sql migration files to the generatedSql/ folder. Use this skill whenever
  the SQL Writer Agent is about to create or update a file.
---

# File Writer Skill

Everything about how migration files are named, structured, and written to disk.

---

## Output folder

All files go to `generatedSql/` relative to the project root. Never write SQL to any other location.

```
project-root/
└── generatedSql/
    ├── 001_guilds.sql
    ├── 002_guild_ranks.sql
    └── 003_guild_invites.sql
```

---

## File naming

Format: `<NNN>_<feature_slug>.sql`

| Part           | Rule                                                                                                                            |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `NNN`          | 3-digit zero-padded sequence number. Read existing files to determine next number. If `generatedSql/` is empty, start at `001`. |
| `feature_slug` | `snake_case` short name from the spec's **Feature Name**. Strip articles and prepositions. Max 40 chars.                        |

Examples:

- "Guild System" → `001_guild_system.sql`
- "Player Inventory" → `002_player_inventory.sql`
- "Map Fog of War Extension" → `003_map_fog_of_war.sql`

**Before naming a new file:** list the contents of `generatedSql/` to find the current highest sequence number and
increment by 1.

---

## File header

Every file must begin with this exact header block:

```sql
-- ============================================================
-- Migration: <Feature Name from spec>
-- Schema(s): <comma-separated list of schemas touched>
-- Tables:    <count> new
-- Functions: <count> automatic_get_api, <count> get_api, <count> action_api
-- Generated: <YYYY-MM-DD>
-- Source:    planner spec → sql-writer-agent
-- ============================================================
```

Followed immediately by `BEGIN;` on the next line.

---

## File internal structure

Sections must appear in this exact order, each with a section divider comment:

```sql
-- ============================================================
-- Migration: Guild System
-- Schema(s): guilds, knowledge
-- Tables:    2 new
-- Functions: 2 automatic_get_api, 3 get_api, 4 action_api
-- Generated: 2025-01-15
-- Source:    planner spec → sql-writer-agent
-- ============================================================

BEGIN;

-- ── 1. Reference / dictionary tables ────────────────────────────────────────

CREATE TABLE IF NOT EXISTS guilds.guild_types ( ... );
CREATE INDEX IF NOT EXISTS ...;


-- ── 2. State tables ──────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS guilds.guilds ( ... );
CREATE TABLE IF NOT EXISTS guilds.guild_members ( ... );
CREATE INDEX IF NOT EXISTS ...;


-- ── 3. Reference data functions (automatic_get_api) ──────────────────────────

CREATE OR REPLACE FUNCTION guilds.get_guild_types() ...;
COMMENT ON FUNCTION guilds.get_guild_types() IS 'automatic_get_api';

CREATE OR REPLACE FUNCTION guilds.get_guild_type_by_key(p_id integer) ...;
COMMENT ON FUNCTION guilds.get_guild_type_by_key(integer) IS 'automatic_get_api';


-- ── 4. Player read functions (get_api) ───────────────────────────────────────

CREATE OR REPLACE FUNCTION guilds.get_player_guild(p_player_id integer) ...;
COMMENT ON FUNCTION guilds.get_player_guild(integer) IS 'get_api';


-- ── 5. Action functions (action_api) ─────────────────────────────────────────

CREATE OR REPLACE FUNCTION guilds.do_create_guild(...) ...;
COMMENT ON FUNCTION guilds.do_create_guild(integer, text) IS 'action_api';


COMMIT;
```

Rules:

- Two blank lines between each top-level object (table or function definition)
- One blank line between a function body and its `COMMENT ON FUNCTION`
- The `COMMIT;` is the very last line — nothing after it

---

## COMMENT ON FUNCTION placement

`COMMENT ON FUNCTION` always comes immediately after the function's closing `$$;`, on its own line:

```sql
-- correct
CREATE OR REPLACE FUNCTION schema.my_func(p_id integer)
...
$$;
COMMENT ON FUNCTION schema.my_func(integer)
    IS 'get_api';


-- wrong — don't put it inside the function or far away
```

The argument list in `COMMENT ON FUNCTION` must match the actual parameter types exactly (no parameter names, just
types):

- `schema.my_func(integer)` ✓
- `schema.my_func(p_id integer)` ✗
- `schema.my_func(integer, text)` ✓

---

## Handling multiple files from one spec

Split into multiple files when the spec says so, OR when:

- The migration touches more than 3 unrelated schemas
- There are more than 15 functions total
- The spec explicitly lists independent modules

Naming when splitting one feature across files:

```
001_guilds_core.sql          # tables + reference data
002_guilds_reads.sql         # get_api functions
003_guilds_actions.sql       # action_api functions
```

---

## File size guideline

A single migration file should be readable in one sitting. If a file exceeds ~600 lines, split it by section (tables /
reads / actions).

---

## Verification checklist before saving

Run through this before writing the file:

- [ ] File is in `generatedSql/`
- [ ] Sequence number is correct (checked existing files)
- [ ] Header block is complete and accurate
- [ ] Sections are in the correct order
- [ ] Every `CREATE TABLE` has `IF NOT EXISTS`
- [ ] Every FK column has a `CREATE INDEX IF NOT EXISTS`
- [ ] Every `automatic_get_api` function has its pair (list + by_key)
- [ ] Every function has `COMMENT ON FUNCTION` immediately after `$$;`
- [ ] `COMMENT ON FUNCTION` uses type-only argument list (no `p_` names)
- [ ] Every `action_api` ends with `EXCEPTION WHEN OTHERS THEN RETURN QUERY SELECT false, SQLERRM::text;`
- [ ] File starts with `BEGIN;` (after header) and ends with `COMMIT;`
- [ ] No `SELECT *` anywhere in the file
