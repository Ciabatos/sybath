import { dbClient } from "./db-client"
import { createFieldDefinition, FieldDefinition } from "./type-mapping"

export interface ColumnInfo {
  column_name: string
  data_type: string
  is_nullable: string
}

export const fetchSchemas = async (): Promise<string[]> => {
  return dbClient.withConnection(async (client) => {
    const res = await client.query(
      `SELECT schema_name
       FROM information_schema.schemata
       WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
       ORDER BY schema_name`
    )
    return res.rows.map((r) => r.schema_name)
  })
}

export const fetchTables = async (schema: string): Promise<string[]> => {
  return dbClient.withConnection(async (client) => {
    const res = await client.query(
      `SELECT table_name
       FROM information_schema.tables
       WHERE table_schema = $1 AND table_type = 'BASE TABLE'
       ORDER BY table_name`,
      [schema]
    )
    return res.rows.map((r) => r.table_name)
  })
}

export const fetchColumns = async (
  schema: string,
  table: string
): Promise<FieldDefinition[]> => {
  if (!table) throw new Error("Table name is required")

  return dbClient.withConnection(async (client) => {
    const res = await client.query<ColumnInfo>(
      `SELECT column_name, data_type, is_nullable
       FROM information_schema.columns
       WHERE table_schema = $1 AND table_name = $2
       ORDER BY ordinal_position`,
      [schema, table]
    )

    return res.rows.map((col) =>
      createFieldDefinition(
        col.column_name,
        col.data_type,
        col.is_nullable === "YES"
      )
    )
  })
}

export const fetchFunctions = async (schema: string): Promise<string[]> => {
  return dbClient.withConnection(async (client) => {
    const res = await client.query(
      `SELECT proname
       FROM pg_proc p
       JOIN pg_namespace n ON p.pronamespace = n.oid
       WHERE n.nspname = $1 AND p.prokind = 'f'
       ORDER BY proname`,
      [schema]
    )
    return res.rows.map((r) => r.proname)
  })
}

export const fetchFunctionArgs = async (
  schema: string,
  functionName: string
): Promise<string> => {
  return dbClient.withConnection(async (client) => {
    const res = await client.query(
      `SELECT pg_get_function_arguments(p.oid) AS args
       FROM pg_proc p
       JOIN pg_namespace n ON p.pronamespace = n.oid
       WHERE n.nspname = $1 AND p.proname = $2`,
      [schema, functionName]
    )

    if (!res.rows[0]) {
      throw new Error(`Function ${schema}.${functionName} not found`)
    }

    return res.rows[0].args || ""
  })
}

export const fetchFunctionReturnType = async (
  schema: string,
  functionName: string
): Promise<string> => {
  return dbClient.withConnection(async (client) => {
    const res = await client.query(
      `SELECT pg_get_function_result(p.oid) AS result
       FROM pg_proc p
       JOIN pg_namespace n ON p.pronamespace = n.oid
       WHERE n.nspname = $1 AND p.proname = $2`,
      [schema, functionName]
    )

    if (!res.rows[0]) {
      throw new Error(`Function ${schema}.${functionName} not found`)
    }

    return res.rows[0].result
  })
}
