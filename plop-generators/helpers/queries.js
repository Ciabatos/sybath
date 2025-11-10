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

export async function fetchFunction(schema) {
  const client = createClient()
  await client.connect()
  try {
    const res = await client.query(
      `
      SELECT p.proname
      FROM pg_proc p
      JOIN pg_namespace n ON n.oid = p.pronamespace
      WHERE n.nspname = $1
        AND p.prokind = 'f'
        AND pg_get_function_result(p.oid) NOT LIKE '%status%'
        AND pg_get_function_result(p.oid) NOT LIKE '%message%'
      ORDER BY proname;
    `,
      [schema],
    )
    return res.rows.map((r) => r.proname)
  } finally {
    await client.end()
  }
}

export async function fetchFucntionForAction(schema) {
  const client = createClient()
  await client.connect()
  try {
    const res = await client.query(
      `
      SELECT p.proname
      FROM pg_proc p
      JOIN pg_namespace n ON n.oid = p.pronamespace
      WHERE n.nspname = $1
        AND p.prokind = 'f'
        AND pg_get_function_result(p.oid) LIKE '%status%'
        AND pg_get_function_result(p.oid) LIKE '%message%'
      ORDER BY proname;

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

export async function createMethodGetRecords(schema, table) {
  const client = createClient()
  await client.connect()
  try {
    const sql = `
      CREATE OR REPLACE FUNCTION ${schema}.get_${table}()
      RETURNS SETOF ${schema}.${table}
      LANGUAGE plpgsql
      AS $$
      BEGIN
          RETURN QUERY
          SELECT * FROM ${schema}.${table};
      END;
      $$;
    `
    await client.query(sql)
    return true
  } finally {
    await client.end()
  }
}

export async function createMethodGetRecordsByKey(schema, table, indexParamsColumns) {
  const client = createClient()
  await client.connect()
  try {
    // Normalize input to array of column names (accept "a,b" or ["a","b"])
    const cols = Array.isArray(indexParamsColumns)
      ? indexParamsColumns.map((c) => String(c).trim()).filter(Boolean)
      : String(indexParamsColumns || "")
          .split(",")
          .map((c) => c.trim())
          .filter(Boolean)

    if (cols.length === 0) {
      throw new Error("indexParamsColumns must contain at least one column name")
    }

    // helper: convert camelCase to snake_case if needed
    const camelToSnake = (s) => (s.includes("_") ? s : s.replace(/([A-Z])/g, "_$1").toLowerCase())

    // map to DB column names (snake_case)
    const dbCols = cols.map((c) => camelToSnake(c))

    // Pobierz typy kolumn z information_schema (data_type + character_maximum_length)
    const resCols = await client.query(
      `
      SELECT column_name, data_type, character_maximum_length
      FROM information_schema.columns
      WHERE table_schema = $1 AND table_name = $2 AND column_name = ANY($3::text[])
    `,
      [schema, table, dbCols],
    )

    const typeMap = {}
    resCols.rows.forEach((r) => {
      let typeStr = r.data_type
      // dopasuj długość dla character varying
      if (r.data_type === "character varying" && r.character_maximum_length) {
        typeStr = `character varying(${r.character_maximum_length})`
      }
      typeMap[r.column_name] = typeStr
    })

    const missing = dbCols.filter((c) => !typeMap[c])
    if (missing.length) {
      throw new Error(`Columns not found in ${schema}.${table}: ${missing.join(", ")}`)
    }

    // Zbuduj definicję parametrów i klauzulę WHERE (p_<col>)
    const paramsDef = dbCols.map((c) => `p_${c} ${typeMap[c]}`).join(", ")
    const whereClause = dbCols.map((c) => `"${c}" = p_${c}`).join(" AND ")
    console.log(paramsDef, whereClause)
    const sql = `
      CREATE OR REPLACE FUNCTION ${schema}.get_${table}_by_key(${paramsDef})
      RETURNS SETOF ${schema}.${table}
      LANGUAGE plpgsql
      AS $$
      BEGIN
          RETURN QUERY
          SELECT * FROM ${schema}.${table}
          WHERE ${whereClause};
      END;
      $$;
    `

    await client.query(sql)
    return true
  } finally {
    await client.end()
  }
}
