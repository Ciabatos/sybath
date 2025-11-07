import { createClient } from "./dbClient.js"
import { mapSQLTypeToTS, snakeToCamel } from "./helpers.js"

export async function fetchSchemas() {
  const client = createClient()
  await client.connect()
  try {
    const res = await client.query(`
      SELECT schema_name
      FROM information_schema.schemata
      WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
      ORDER BY schema_name
    `)
    return res.rows.map((r) => r.schema_name)
  } finally {
    await client.end()
  }
}

export async function fetchTables(schema) {
  const client = createClient()
  await client.connect()
  try {
    const res = await client.query(
      `
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = $1 AND table_type = 'BASE TABLE'
      ORDER BY table_name
    `,
      [schema],
    )
    return res.rows.map((r) => r.table_name)
  } finally {
    await client.end()
  }
}

export async function fetchColumns(schema, table) {
  if (!table) throw new Error("Table name is required")
  const client = createClient()
  try {
    await client.connect()
    const res = await client.query(
      `
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_schema = $1 AND table_name = $2
      ORDER BY ordinal_position
    `,
      [schema, table],
    )
    return res.rows
  } finally {
    await client.end()
  }
}

export async function fetchFunctions(schema) {
  const client = createClient()
  await client.connect()
  try {
    const res = await client.query(
      `
      SELECT proname
      FROM pg_proc p
      JOIN pg_namespace n ON p.pronamespace = n.oid
      WHERE n.nspname = $1 AND p.prokind = 'f'
      ORDER BY proname
    `,
      [schema],
    )
    return res.rows.map((r) => r.proname)
  } finally {
    await client.end()
  }
}

export async function fetchMethodArgs(schema, method) {
  const client = createClient()
  await client.connect()
  try {
    const res = await client.query(
      `
      SELECT pg_get_function_arguments(p.oid) AS args
      FROM pg_proc p
      JOIN pg_namespace n ON p.pronamespace = n.oid
      WHERE n.nspname = $1 AND p.proname = $2
    `,
      [schema, method],
    )
    if (!res.rows[0]) throw new Error(`Function ${schema}.${method} not found`)
    return res.rows[0].args || ""
  } finally {
    await client.end()
  }
}

export async function fetchMethodResultColumns(schema, method) {
  const client = createClient()
  await client.connect()
  try {
    const res = await client.query(
      `
      SELECT pg_get_function_result(p.oid) AS result
      FROM pg_proc p
      JOIN pg_namespace n ON p.pronamespace = n.oid
      WHERE n.nspname = $1 AND p.proname = $2
    `,
      [schema, method],
    )
    if (!res.rows[0]) throw new Error(`Function ${schema}.${method} not found`)

    const resultType = res.rows[0].result
    if (!resultType.startsWith("TABLE(")) {
      return [{ name: "result", camelName: "result", type: mapSQLTypeToTS(resultType) }]
    }

    const tableMatch = resultType.match(/TABLE\((.*?)\)/)
    if (!tableMatch) return [{ name: "result", camelName: "result", type: "any" }]

    return tableMatch[1]
      .split(",")
      .map((col) => {
        const [name, type] = col.trim().split(" ")
        return name && type
          ? {
              name,
              camelName: snakeToCamel(name),
              pascalName: snakeToCamel(name),
              type: mapSQLTypeToTS(type),
            }
          : null
      })
      .filter(Boolean)
  } finally {
    await client.end()
  }
}
