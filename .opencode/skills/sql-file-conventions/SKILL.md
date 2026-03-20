---
name: sql-file-conventions
description: >
  All SQL style rules, patterns, and templates for the RPG game database. Use this skill when writing any SQL for the
  RPG project to ensure consistency with the existing codebase.
---

# SQL Conventions Skill

Complete reference for every SQL pattern used in the RPG database. Read this before writing a single line of SQL.

---

## Naming rules

| Object             | Convention                       | Example                            |
| ------------------ | -------------------------------- | ---------------------------------- |
| Schemas            | `snake_case`                     | `inventory`, `world`               |
| Tables             | `snake_case`, plural             | `guild_members`, `item_slots`      |
| Columns            | `snake_case`                     | `player_id`, `created_at`          |
| Primary key        | always `id`                      | `id SERIAL PRIMARY KEY`            |
| Foreign keys       | `<referenced_table_singular>_id` | `player_id`, `item_id`, `guild_id` |
| Function params    | `p_` prefix                      | `p_player_id`, `p_amount`          |
| Local variables    | `v_` prefix                      | `v_guild_record`, `v_count`        |
| Indexes            | `idx_<table>_<column(s)>`        | `idx_guild_members_player_id`      |
| Unique constraints | `uq_<table>_<columns>`           | `uq_guild_members_player_id`       |
| Check constraints  | `chk_<table>_<description>`      | `chk_slots_amount_positive`        |

---

## Table template

```sql
CREATE TABLE IF NOT EXISTS schema.table_name (
    id           SERIAL          PRIMARY KEY,
    player_id    INTEGER         NOT NULL
                                 REFERENCES players.players(id)
                                 ON DELETE CASCADE,
    some_ref_id  INTEGER         NOT NULL
                                 REFERENCES schema.ref_table(id),
    name         TEXT            NOT NULL,
    amount       INTEGER         NOT NULL    DEFAULT 1,
    metadata     JSONB,
    is_active    BOOLEAN         NOT NULL    DEFAULT true,
    created_at   TIMESTAMPTZ     NOT NULL    DEFAULT now(),
    updated_at   TIMESTAMPTZ     NOT NULL    DEFAULT now(),

    CONSTRAINT uq_table_name_player_id_ref UNIQUE (player_id, some_ref_id),
    CONSTRAINT chk_table_name_amount_positive CHECK (amount > 0)
);

-- Index every FK column
CREATE INDEX IF NOT EXISTS idx_table_name_player_id   ON schema.table_name(player_id);
CREATE INDEX IF NOT EXISTS idx_table_name_some_ref_id ON schema.table_name(some_ref_id);
-- Index columns used in WHERE filters
CREATE INDEX IF NOT EXISTS idx_table_name_is_active   ON schema.table_name(is_active)
    WHERE is_active = true;  -- partial index when filtering one value
```

Rules:

- `IF NOT EXISTS` always
- One column per line, aligned
- FK `ON DELETE` behaviour must be explicit (`CASCADE`, `SET NULL`, or `RESTRICT`)
- `TIMESTAMPTZ` (not `TIMESTAMP`) for all timestamps
- `TEXT` (not `VARCHAR`) for variable-length strings
- `JSONB` (not `JSON`) for JSON columns
- Comments after the closing `;` if a column needs explanation

---

## automatic_get_api — dictionary pair template

```sql
-- ── <Name> dictionary ─────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION world.get_landscape_types()
 RETURNS SETOF world.landscape_types
 LANGUAGE plpgsql
AS $function$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM world.landscape_types;
      END;
      $function$
;

COMMENT ON FUNCTION world.get_landscape_types() IS 'automatic_get_api';


CREATE OR REPLACE FUNCTION world.get_landscape_types_by_key(p_id integer)
 RETURNS SETOF world.landscape_types
 LANGUAGE plpgsql
AS $function$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM world.landscape_types
          WHERE "id" = p_id;
      END;
      $function$
;

COMMENT ON FUNCTION world.get_landscape_types_by_key(int4) IS 'automatic_get_api';

```

---

## get_api — player context template

```sql
-- ── Get <description> ─────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION schema.get_player_<name>(
    p_player_id integer
)
RETURNS TABLE (
    col1  integer,
    col2  text,
    col3  timestamptz
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
        SELECT
            t.col1,
            t.col2,
            t.col3
        FROM schema.some_table t
        WHERE t.player_id = p_player_id
        ORDER BY t.created_at DESC;
END;
$$;
COMMENT ON FUNCTION schema.get_player_<name>(integer)
    IS 'get_api';
```

Knowledge variant (when returning data that is within knowledge schema):

```sql
CREATE OR REPLACE FUNCTION schema.get_player_<name>(
    p_player_id integer
)
RETURNS TABLE (
    tile_id     integer,
    x           integer,
    y           integer,
    revealed_at timestamptz
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
        SELECT
            t.id,
            t.x,
            t.y,
            k.discovered_at
        FROM schema.tiles t
        -- Join knowledge table — only return tiles the player knows about
        JOIN knowledge.known_map_tiles k
            ON  k.tile_id    = t.id
            AND k.player_id  = p_player_id
        ORDER BY t.id;
END;
$$;
COMMENT ON FUNCTION schema.get_player_<name>(integer)
    IS 'get_api';
```

Rules:

- First parameter always `p_player_id integer`
- `LANGUAGE plpgsql` (allows control flow)
- `STABLE` unless the function logs access
- Never filter out rows the player "shouldn't known about" — return NULL fields instead, or join `knowledge.*`
- `RETURN QUERY SELECT ...` — never `RETURN NEXT`

---

## action_api — game action template

```sql
-- ── Do <action> ───────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb)
 RETURNS TABLE(status boolean, message text)
 LANGUAGE plpgsql
AS $function$
DECLARE
    param jsonb;
    base_time timestamp;
    scheduled_at timestamp;
BEGIN

/* MUTEX */
PERFORM 1
FROM players.players
WHERE id = p_player_id
FOR UPDATE;

    PERFORM tasks.cancel_task(p_player_id, 'world.player_movement');

SELECT COALESCE(MAX(t1.scheduled_at), NOW())
INTO base_time
FROM tasks.tasks t1
WHERE t1.player_id = p_player_id
  AND t1.status IN (1, 2);

    FOR param IN
        SELECT * FROM jsonb_array_elements(p_path)
    LOOP
          scheduled_at := base_time
               + ((param->>'totalMoveCost')::int * interval '1 minute');

        PERFORM tasks.insert_task(p_player_id, scheduled_at , 'world.player_movement', param);
    END LOOP;

    RETURN QUERY SELECT true, 'Movement actions assigned';
END;
$function$
;

COMMENT ON FUNCTION world.do_player_movement(int4, jsonb) IS 'action_api';

```

## General SQL style

```sql
-- Keywords: UPPERCASE
-- Identifiers: lowercase
-- One clause per line for multi-line statements
-- Align ON, WHERE, AND, OR at same indent level

SELECT
    t.id,
    t.player_id,
    t.created_at
FROM schema.table t
JOIN schema.other o
    ON  o.id        = t.other_id
    AND o.is_active = true
WHERE t.player_id = p_player_id
  AND t.created_at > now() - interval '30 days'
ORDER BY t.created_at DESC;
```

- `-- ── Section header ─────` for visual separation between function sections
- `-- Inline comment` for single-line explanations
- Block comments `/* ... */` only for multi-paragraph explanations
- No trailing whitespace
- Two blank lines between function definitions
