---
name: sql-game-design-spec
description: >
  Defines the exact output format the Planning Agent must produce. The spec is the contract between the planner and the
  SQL Migration Agent. Use this skill to format the final output of every planning session.
---

# Spec Format Skill

The planning agent's output is a structured specification document followed by a ready-to-use prompt for the SQL
Migration Agent.

---

## Specification document format

```markdown
# Feature Spec: <Feature Name>

## Summary

One paragraph: what this feature does, who uses it, and why it exists in the game.

## Scope

- **Schema(s):** list of PostgreSQL schemas this feature touches
- **New tables:** count
- **New functions:** count broken down by api_type
- **Modifies existing:** yes/no — list tables/functions if yes

---

## Existing schema observations

_(from MCP — document what you found before designing)_

### Relevant tables found

| Table           | Schema  | Key columns used |
| --------------- | ------- | ---------------- |
| players.players | players | id, ...          |
| ...             |         |                  |

### Relevant functions found

| Function | Type    | Signature |
| -------- | ------- | --------- |
| ...      | get_api | ...       |

### Conventions observed

- Parameter naming: `p_` prefix, player id is `p_player_id integer`
- Primary keys: `SERIAL` or `BIGSERIAL`
- FK pattern: `<table>_id integer REFERENCES schema.table(id)`
- (any other conventions noticed from the live schema)

---

## New tables

### `schema.table_name`

_Purpose: one sentence_

| Column     | Type        | Nullable | Default | Notes                                      |
| ---------- | ----------- | -------- | ------- | ------------------------------------------ |
| id         | SERIAL      | NO       | auto    | PK                                         |
| player_id  | INTEGER     | NO       |         | FK → players.players(id) ON DELETE CASCADE |
| ...        |             |          |         |                                            |
| created_at | TIMESTAMPTZ | NO       | now()   |                                            |
| updated_at | TIMESTAMPTZ | NO       | now()   | (if mutable)                               |

**Indexes:**

- `idx_<table>_player_id` ON `player_id`
- `idx_<table>_<col>` ON `<col>` — (explain why)

**Constraints:**

- UNIQUE on `(player_id, other_col)` — (explain why)
- CHECK `amount > 0`

_(repeat for each new table)_

---

## Reference data (automatic_get_api)

### `schema.get_<name>()`

- **Returns:** `TABLE(id integer, name text, ...)`
- **Purpose:** returns all rows from `schema.<name>` for client dropdowns/lookups

### `schema.get_<name>_by_key(p_id integer)`

- **Returns:** `TABLE(id integer, name text, ...)`
- **Purpose:** returns single row by PK

_(repeat pairs for each reference table)_

---

## Player read functions (get_api)

### `schema.get_<feature>(p_player_id integer)`

- **Returns:** `TABLE(<col> <type>, ...)`
- **Purpose:** what the player can see about their own state in this feature
- **Fog-of-war:** yes/no — if yes, describe which `knowledge.*` table gates visibility
- **Logic summary:**
  1. ...
  2. ...
- **Edge cases:** returns empty set if player has no data yet (not an error)

_(repeat for each get_api function)_

---

## Action functions (action_api)

### `schema.do_<action>(p_player_id integer, p_param type, ...)`

- **Returns:** `TABLE(status boolean, message text)`
- **Purpose:** one sentence
- **Parameters:** | Param | Type | Description | |-------|------|-------------| | p_player_id | integer | acting player
  | | p_target_id | integer | target entity | | ... | | |
- **Happy path:**
  1. Validate player exists and is active
  2. Check preconditions (list them)
  3. Apply changes (list INSERT/UPDATE/DELETE operations)
  4. Return `(true, 'success message')`
- **Failure cases:** | Condition | Returns | |-----------|---------| | Player not found | `(false, 'Player not found')`
  | | Already a member | `(false, 'Already a member of a guild')` | | Guild at capacity | `(false, 'Guild is full')` | |
  ... | |
- **Async:** yes/no — if yes, describe task type
- **Side effects:** list any inserts into `knowledge.*`, `tasks.tasks`, or other schemas

_(repeat for each action_api function)_

---

## Migration script structure

The SQL agent should produce one file: `<feature_name>_migration.sql`

Sections in order:

1. New reference/dictionary tables + seed data (if any)
2. New state tables + indexes + constraints
3. `automatic_get_api` function pairs
4. `get_api` functions
5. `action_api` functions
6. All `COMMENT ON FUNCTION` statements

Everything inside `BEGIN; ... COMMIT;`

---

## Open questions

_(list any design decisions that were left ambiguous and how you resolved them, or ones that need a human decision)_

- [ ] Resolved: max guild size — defaulted to 50, configurable via reference table
- [ ] Needs decision: should guild names be unique globally or per-server?
```

---

## Handoff prompt format

After the spec, always output this block — it's the exact prompt to give the SQL Migration Agent:

```
---
## Handoff to SQL Migration Agent

@sql-agent

Please implement the following feature according to this spec.

**Feature:** <Feature Name>
**Target schema(s):** <list>
**Migration file name:** <feature_name>_migration.sql

### What to build

<paste the Tables, Functions, and Migration script structure sections from above>

### Conventions reminder
- Read the live schema via MCP before writing any SQL (get_schema, then drill as needed)
- Follow SKILL.md conventions exactly
- Parameter prefix: p_
- action_api always returns TABLE(status boolean, message text)
- Every function gets a COMMENT ON FUNCTION
- Script wrapped in BEGIN; ... COMMIT;
---
```

---

## Quality bar for a good spec

A spec is ready to hand off when:

- [ ] Every new table has all columns defined with types, nullability, defaults, and FK targets verified from live
      schema
- [ ] Every FK target was confirmed via MCP (not assumed)
- [ ] Every `get_api` function specifies fog-of-war behaviour
- [ ] Every `action_api` function has a complete failure cases table
- [ ] Every `action_api` function specifies whether it queues an async task
- [ ] The migration script structure section lists sections in the right order
- [ ] No ambiguity remains that would require the SQL agent to make a design decision
