// ─────────────────────────────────────────────────────────────────────────────
// Constants: SQL queries and configuration
// ─────────────────────────────────────────────────────────────────────────────

/** Schemas excluded from all discovery queries (system + admin-only) */
export const EXCLUDED_SCHEMAS = ["pg_catalog", "information_schema", "admin", "util"] as const

/** Only functions with one of these comments are exposed via MCP */
export const ALLOWED_API_TYPES = ["automatic_get_api", "get_api", "action_api"] as const

/** Maximum response size in characters before truncation warning is added */
export const CHARACTER_LIMIT = 40_000

/**
 * Returns all base tables with their columns from non-system schemas.
 * One row per column — caller must group by (table_schema, table_name).
 * Optionally filtered by schema via $1 parameter.
 */
export const SQL_GET_TABLES = `
SELECT
  t.table_schema,
  t.table_name,
  c.column_name,
  c.data_type,
  c.is_nullable,
  c.column_default
FROM information_schema.tables  t
JOIN information_schema.columns c
  ON  c.table_schema = t.table_schema
  AND c.table_name   = t.table_name
WHERE t.table_schema NOT IN (${EXCLUDED_SCHEMAS.map((s) => `'${s}'`).join(", ")})
  AND t.table_type = 'BASE TABLE'
  AND ($1::text IS NULL OR t.table_schema = $1)
ORDER BY t.table_schema, t.table_name, c.ordinal_position;
`.trim()

/**
 * Returns ALL functions and procedures from user schemas — no comment filter.
 * Optionally filtered by schema ($1) and/or name substring ($2).
 * kind: 'f' = function, 'p' = procedure.
 */
export const SQL_GET_ALL_FUNCTIONS = `
SELECT
  n.nspname                              AS schema,
  p.proname                              AS function_name,
  pg_get_function_arguments(p.oid)       AS arguments,
  pg_get_function_result(p.oid)          AS return_type,
  obj_description(p.oid, 'pg_proc')      AS comment,
  CASE p.prokind WHEN 'p' THEN 'procedure' ELSE 'function' END AS kind,
  l.lanname                              AS language
FROM pg_proc      p
JOIN pg_namespace n ON n.oid = p.pronamespace
JOIN pg_language  l ON l.oid = p.prolang
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
  AND ($1::text IS NULL OR n.nspname = $1)
  AND ($2::text IS NULL OR p.proname ILIKE '%' || $2 || '%')
ORDER BY n.nspname, p.proname;
`.trim()

/**
 * Returns the full SQL source of a single function/procedure.
 * $1 = schema name, $2 = function name.
 * Returns one row per overload (same name, different argument signature).
 */
export const SQL_GET_FUNCTION_DEFINITION = `
SELECT
  n.nspname                              AS schema,
  p.proname                              AS function_name,
  pg_get_function_arguments(p.oid)       AS arguments,
  pg_get_function_result(p.oid)          AS return_type,
  obj_description(p.oid, 'pg_proc')      AS comment,
  CASE p.prokind WHEN 'p' THEN 'procedure' ELSE 'function' END AS kind,
  l.lanname                              AS language,
  pg_get_functiondef(p.oid)              AS definition
FROM pg_proc      p
JOIN pg_namespace n ON n.oid = p.pronamespace
JOIN pg_language  l ON l.oid = p.prolang
WHERE n.nspname = $1
  AND p.proname = $2
ORDER BY pg_get_function_arguments(p.oid);
`.trim()

/**
 * Returns all functions that have an api-type comment.
 * Optionally filtered by api_type via $1 parameter.
 */
export const SQL_GET_FUNCTIONS = `
SELECT
  n.nspname                              AS schema,
  p.proname                              AS function_name,
  pg_get_function_arguments(p.oid)       AS arguments,
  pg_get_function_result(p.oid)          AS return_type,
  obj_description(p.oid, 'pg_proc')      AS comment
FROM pg_proc      p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname NOT IN (${EXCLUDED_SCHEMAS.map((s) => `'${s}'`).join(", ")})
  AND obj_description(p.oid, 'pg_proc') IN (${ALLOWED_API_TYPES.map((t) => `'${t}'`).join(", ")})
  AND ($1::text IS NULL OR obj_description(p.oid, 'pg_proc') = $1)
ORDER BY n.nspname, p.proname;
`.trim()
