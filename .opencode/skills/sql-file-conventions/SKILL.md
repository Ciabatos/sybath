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

CREATE OR REPLACE FUNCTION schema.get_<name>s()
RETURNS TABLE (
    id          integer,
    name        text,
    description text
    -- mirror all columns the client needs
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT
        id,
        name,
        description
    FROM schema.<name>s
    ORDER BY id;
$$;
COMMENT ON FUNCTION schema.get_<name>s()
    IS 'automatic_get_api';

CREATE OR REPLACE FUNCTION schema.get_<name>_by_key(p_id integer)
RETURNS TABLE (
    id          integer,
    name        text,
    description text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT
        id,
        name,
        description
    FROM schema.<name>s
    WHERE id = p_id;
$$;
COMMENT ON FUNCTION schema.get_<name>_by_key(integer)
    IS 'automatic_get_api';
```

Rules:

- Always create the pair — never just one
- `LANGUAGE sql` (not plpgsql) for simple selects
- `STABLE` — safe to cache
- `SECURITY DEFINER` — consistent privilege model
- `ORDER BY id` on the list function
- Column list in `RETURNS TABLE` must name every column explicitly

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

Fog-of-war variant (when returning world/positional data):

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
- Never filter out rows the player "shouldn't see" — return NULL fields instead, or join `knowledge.*`
- `RETURN QUERY SELECT ...` — never `RETURN NEXT`

---

## action_api — game action template

```sql
-- ── Do <action> ───────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION schema.do_<action>(
    p_player_id  integer,
    p_target_id  integer
    -- more params...
)
RETURNS TABLE (
    status   boolean,
    message  text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_player   record;
    v_target   record;
    -- more local vars...
BEGIN
    -- ── 1. Load and validate player ──────────────────────────────────────────
    SELECT * INTO v_player
    FROM players.players
    WHERE id = p_player_id;

    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Player not found'::text;
        RETURN;
    END IF;

    -- ── 2. Load and validate target ──────────────────────────────────────────
    SELECT * INTO v_target
    FROM schema.targets
    WHERE id = p_target_id;

    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Target not found'::text;
        RETURN;
    END IF;

    -- ── 3. Business rule checks ──────────────────────────────────────────────
    IF <condition> THEN
        RETURN QUERY SELECT false, 'Descriptive reason'::text;
        RETURN;
    END IF;

    -- ── 4. Apply changes ─────────────────────────────────────────────────────
    INSERT INTO schema.table (...) VALUES (...);
    -- or UPDATE / DELETE

    -- ── 5. Queue async task (if needed) ──────────────────────────────────────


    -- ── 6. Success ───────────────────────────────────────────────────────────
    RETURN QUERY SELECT true, 'Action completed successfully'::text;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, SQLERRM::text;
END;
$$;
COMMENT ON FUNCTION schema.do_<action>(integer, integer)
    IS 'action_api';
```

Rules:

- Returns `TABLE(status boolean, message text)` — always, no exceptions
- Each validation step: `IF NOT FOUND / IF condition THEN RETURN QUERY SELECT false, '...' RETURN; END IF;`
- `RETURN;` (bare) after every early exit — mandatory
- `EXCEPTION WHEN OTHERS THEN RETURN QUERY SELECT false, SQLERRM::text;` — always last
- No `SECURITY DEFINER` unless elevated access is required
- Variable naming: `v_<noun>` for local, `p_<noun>` for params
- Use `record` type for SELECT INTO when you need multiple columns
- Success message: short, present tense, specific (`'Guild created'`, not `'success'`)
- Failure messages: start with capital letter, no trailing punctuation

---

## JSONB action params (complex step arrays)

When an action takes a list of steps (movement path, batch operations):

```sql
CREATE OR REPLACE FUNCTION schema.do_<action>(
    p_player_id  integer,
)
RETURNS TABLE(status boolean, message text)
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
BEGIN



    RETURN QUERY SELECT true, 'Steps applied'::text;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, SQLERRM::text;
END;
$$;
```

---

## async task queuing

When an action should schedule deferred work:

```sql
-- Inside an action_api function body:
INSERT INTO tasks.tasks (
    task_type,
    player_id,
    payload,
    execute_at,
    created_at
)
VALUES (
    'guild_invite_expire',
    p_player_id,
    jsonb_build_object(
        'guild_id',  v_guild.id,
        'invite_id', v_invite.id
    ),
    now() + interval '48 hours',
    now()
);
```

Task type string must be `snake_case` and match what the task runner expects. Always document the payload structure in a
SQL comment above the INSERT.

---

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
