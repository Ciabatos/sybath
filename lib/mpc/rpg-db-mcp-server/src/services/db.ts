import "dotenv/config"
import pg, { type QueryResultRow } from "../../node_modules/@types/pg/index.js"
import { SQL_GET_ALL_FUNCTIONS, SQL_GET_FUNCTION_DEFINITION, SQL_GET_FUNCTIONS, SQL_GET_TABLES } from "../constants.js"
import type {
  AnyFunctionInfo,
  FunctionDefinitionInfo,
  FunctionInfo,
  RawAnyFunctionRow,
  RawFunctionDefinitionRow,
  RawFunctionRow,
  RawTableRow,
  TableInfo,
} from "../types.js"
const { Pool } = pg

// ─────────────────────────────────────────────────────────────────────────────
// Connection pool — configured from environment variables
// ─────────────────────────────────────────────────────────────────────────────

let _pool: pg.Pool | null = null

export function getPool(): pg.Pool {
  if (!_pool) {
    _pool = new Pool({
      connectionString:
        process.env.DATABASE_URL ??
        `postgresql://${process.env.DB_USER ?? "postgres"}:${process.env.DB_PASSWORD ?? ""}@${process.env.DB_HOST ?? "localhost"}:${process.env.DB_PORT ?? "5432"}/${process.env.DB_NAME ?? "rpg"}`,
      max: 5,
      idleTimeoutMillis: 30_000,
      connectionTimeoutMillis: 5_000,
    })

    _pool.on("error", (err) => {
      process.stderr.write(`[db] Unexpected pool error: ${err.message}\n`)
    })
  }

  return _pool
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic query helper
// ─────────────────────────────────────────────────────────────────────────────

export async function query<T extends QueryResultRow>(sql: string, params: unknown[] = []): Promise<T[]> {
  const pool = getPool()
  const client = await pool.connect()
  try {
    const result = await client.query<T>(sql, params)
    return result.rows
  } finally {
    client.release()
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Domain helpers — fetch + transform
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Fetch tables, grouping flat column rows into nested TableInfo objects.
 * @param schema  Optional schema filter. Pass null/undefined to get all schemas.
 */
export async function fetchTables(schema?: string | null): Promise<TableInfo[]> {
  const rows = await query<RawTableRow>(SQL_GET_TABLES, [schema ?? null])
  return groupTableRows(rows)
}

/**
 * Fetch API functions, optionally filtered by api_type comment.
 * @param apiType  One of: automatic_get_api | get_api | action_api | null (all)
 */
export async function fetchFunctions(apiType?: string | null): Promise<FunctionInfo[]> {
  const rows = await query<RawFunctionRow>(SQL_GET_FUNCTIONS, [apiType ?? null])
  return rows.map((r) => ({
    schema: r.schema,
    function_name: r.function_name,
    arguments: r.arguments,
    return_type: r.return_type,
    api_type: r.comment,
  }))
}

/**
 * Fetch ALL functions/procedures from user schemas — no api_type comment filter.
 * @param schema   Optional schema filter.
 * @param search   Optional case-insensitive substring match on function name.
 */
export async function fetchAllFunctions(schema?: string | null, search?: string | null): Promise<AnyFunctionInfo[]> {
  const rows = await query<RawAnyFunctionRow>(SQL_GET_ALL_FUNCTIONS, [schema ?? null, search ?? null])
  return rows.map((r) => ({
    schema: r.schema,
    function_name: r.function_name,
    arguments: r.arguments,
    return_type: r.return_type,
    comment: r.comment,
    kind: r.kind === "procedure" ? "procedure" : "function",
    language: r.language,
  }))
}

/**
 * Fetch the full SQL definition of a specific function/procedure.
 * Returns one entry per overload if the function name is overloaded.
 * @param schema        Schema name, e.g. 'world'
 * @param functionName  Function name, e.g. 'get_player_position'
 */
export async function fetchFunctionDefinition(schema: string, functionName: string): Promise<FunctionDefinitionInfo[]> {
  const rows = await query<RawFunctionDefinitionRow>(SQL_GET_FUNCTION_DEFINITION, [schema, functionName])
  return rows.map((r) => ({
    schema: r.schema,
    function_name: r.function_name,
    arguments: r.arguments,
    return_type: r.return_type,
    comment: r.comment,
    kind: r.kind === "procedure" ? "procedure" : "function",
    language: r.language,
    definition: r.definition,
  }))
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal helpers
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Groups flat column rows (one per column) into nested TableInfo objects.
 * Preserves column order (ORDER BY ordinal_position in SQL).
 */
function groupTableRows(rows: RawTableRow[]): TableInfo[] {
  const map = new Map<string, TableInfo>()

  for (const row of rows) {
    const key = `${row.table_schema}.${row.table_name}`

    if (!map.has(key)) {
      map.set(key, {
        schema: row.table_schema,
        table_name: row.table_name,
        columns: [],
      })
    }

    map.get(key)!.columns.push({
      column_name: row.column_name,
      data_type: row.data_type,
      is_nullable: row.is_nullable === "YES",
      column_default: row.column_default,
    })
  }

  return [...map.values()]
}
