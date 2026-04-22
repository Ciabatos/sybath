import { createClient } from "./dbClient.js"
import { mapSQLTypeToTS, snakeToCamel, snakeToPascal } from "./helpers.js"

// ─── DB helper ────────────────────────────────────────────────────────────────

async function withClient(fn) {
  const client = createClient()
  await client.connect()
  try {
    return await fn(client)
  } finally {
    await client.end()
  }
}

// ─── Schema / Table / Column discovery ────────────────────────────────────────

export const fetchSchemas = () =>
  withClient((c) =>
    c
      .query(
        `
      SELECT schema_name FROM information_schema.schemata
      WHERE schema_name NOT IN ('pg_catalog','information_schema','pg_toast')
      ORDER BY schema_name
    `,
      )
      .then((r) => r.rows.map((x) => x.schema_name)),
  )

export const fetchTables = (schema) =>
  withClient((c) =>
    c
      .query(
        `SELECT table_name FROM information_schema.tables
       WHERE table_schema=$1 AND table_type='BASE TABLE' ORDER BY table_name`,
        [schema],
      )
      .then((r) => r.rows.map((x) => x.table_name)),
  )

export const fetchColumns = (schema, table) => {
  if (!table) throw new Error("Table name is required")
  return withClient((c) =>
    c
      .query(
        `SELECT c.column_name, c.data_type, c.is_nullable, d.description
       FROM information_schema.columns c
       LEFT JOIN pg_catalog.pg_class cl      ON cl.relname = c.table_name
       LEFT JOIN pg_catalog.pg_attribute a   ON a.attrelid = cl.oid AND a.attname = c.column_name
       LEFT JOIN pg_catalog.pg_description d ON d.objoid = cl.oid   AND d.objsubid = a.attnum
       WHERE c.table_schema=$1 AND c.table_name=$2
         AND (d.description IS NULL OR d.description != 'get_api')
       ORDER BY c.ordinal_position`,
        [schema, table],
      )
      .then((r) => r.rows),
  )
}

// ─── Function discovery ───────────────────────────────────────────────────────

const fetchFunctionsByComment = (schema, comment) =>
  withClient((c) =>
    c
      .query(
        `SELECT p.proname FROM pg_proc p
       JOIN pg_namespace n    ON n.oid = p.pronamespace
       LEFT JOIN pg_description d ON d.objoid = p.oid
       WHERE n.nspname=$1 AND p.prokind='f' AND d.description=$2
       ORDER BY proname`,
        [schema, comment],
      )
      .then((r) => r.rows.map((x) => x.proname)),
  )

export const fetchFunction = (schema) => fetchFunctionsByComment(schema, "get_api")
export const fetchFucntionForAction = (schema) => fetchFunctionsByComment(schema, "action_api")

// ─── Composite type discovery ─────────────────────────────────────────────────

const COMPOSITE_SQL = `
  SELECT t.typname, a.attname AS column_name, format_type(a.atttypid,a.atttypmod) AS data_type
  FROM pg_type t
  JOIN pg_namespace n    ON n.oid = t.typnamespace
  JOIN pg_class c        ON c.oid = t.typrelid
  JOIN pg_attribute a    ON a.attrelid = c.oid
  LEFT JOIN pg_description d ON d.objoid = t.oid
  WHERE n.nspname=$1 AND d.description=$1||'.'||$2 AND a.attnum>0
  ORDER BY t.typname, a.attnum`

export const fetchCompositeTypeName = (schema, method) =>
  withClient((c) => c.query(COMPOSITE_SQL + " LIMIT 1", [schema, method]).then((r) => r.rows[0]?.typname ?? null))

export const fetchCompositeType = (schema, typeName) =>
  withClient((c) =>
    c.query(COMPOSITE_SQL, [schema, typeName]).then((r) =>
      r.rows.map(({ column_name, data_type }) => ({
        name: column_name,
        camelName: snakeToCamel(column_name),
        tsType: mapSQLTypeToTS(data_type),
      })),
    ),
  )

// ─── Method args / result ─────────────────────────────────────────────────────

export async function fetchMethodArgs(schema, method) {
  const argsStr = await withClient((c) =>
    c
      .query(
        `SELECT pg_get_function_arguments(p.oid) AS args
       FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid
       WHERE n.nspname=$1 AND p.proname=$2`,
        [schema, method],
      )
      .then((r) => {
        if (!r.rows[0]) throw new Error(`Function ${schema}.${method} not found`)
        return r.rows[0].args
      }),
  )

  if (!argsStr) return { methodParamsColumns: [], argsArray: [], argsCompositeTypes: [] }

  const compositeTypes = []
  const parts = argsStr.split(",").map((a) => a.trim())

  const methodParamsColumns = await Promise.all(
    parts.map(async (part) => {
      const sp = part.indexOf(" ")
      if (sp === -1) return null
      const name = part.slice(0, sp)
      const sqlType = part.slice(sp + 1)
      let tsType = mapSQLTypeToTS(sqlType)
      let isJson = false

      if (tsType === "jsonb") {
        isJson = true
        const baseName = await fetchCompositeTypeName(schema, method)
        if (baseName) {
          tsType = `T${snakeToPascal(baseName)}[]`
          if (!compositeTypes.includes(baseName)) compositeTypes.push(baseName)
        }
      }
      return { name, camelName: snakeToCamel(name), tsType, isJson }
    }),
  )

  const argsArray = parts
    .map((p) => {
      const sp = p.indexOf(" ")
      return sp === -1 ? p : p.slice(0, sp)
    })
    .filter(Boolean)

  return {
    methodParamsColumns: methodParamsColumns.filter(Boolean),
    argsArray,
    argsCompositeTypes: compositeTypes,
  }
}

export const fetchMethodFunctionArgs = (schema, method) =>
  withClient((c) =>
    c
      .query(
        `SELECT pg_get_function_arguments(p.oid) AS args
       FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid
       JOIN pg_description d ON d.objoid=p.oid
       WHERE n.nspname=$1 AND p.proname=$2 AND d.description='get_api'`,
        [schema, method],
      )
      .then((r) => {
        if (!r.rows[0]) throw new Error(`Function ${schema}.${method} not found`)
        return r.rows[0].args ?? ""
      }),
  )

export async function fetchMethodResultColumns(schema, method) {
  const resultType = await withClient((c) =>
    c
      .query(
        `SELECT pg_get_function_result(p.oid) AS result
       FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid
       JOIN pg_description d ON d.objoid=p.oid
       WHERE n.nspname=$1 AND p.proname=$2 AND d.description IN ('get_api','action_api')`,
        [schema, method],
      )
      .then((r) => {
        if (!r.rows[0]) throw new Error(`Function ${schema}.${method} not found`)
        return r.rows[0].result
      }),
  )

  if (!resultType.startsWith("TABLE(")) {
    return {
      resultColumns: [{ name: "result", camelName: "result", type: mapSQLTypeToTS(resultType) }],
      compositeTypes: [],
    }
  }

  const tableMatch = resultType.match(/TABLE\((.*?)\)/)
  if (!tableMatch) return { resultColumns: [{ name: "result", camelName: "result", type: "any" }], compositeTypes: [] }

  const compositeTypes = []
  const resultColumns = await Promise.all(
    tableMatch[1].split(",").map(async (col) => {
      const [rawName, type] = col.trim().split(" ")
      if (!rawName || !type) return null
      const name = rawName.replace(/"/g, "")
      let tsType = mapSQLTypeToTS(type)
      let isJson = false

      if (tsType === "jsonb") {
        isJson = true
        const baseName = await fetchCompositeTypeName(schema, method)
        if (baseName) {
          tsType = `T${snakeToPascal(baseName)}[]`
          if (!compositeTypes.includes(baseName)) compositeTypes.push(baseName)
        }
      }
      return { name, camelName: snakeToCamel(name), pascalName: snakeToPascal(name), type: tsType, isJson }
    }),
  )

  return { resultColumns: resultColumns.filter(Boolean), compositeTypes }
}

// ─── Auto-generated DB functions ──────────────────────────────────────────────

export const createMethodGetRecords = (schema, table) =>
  withClient((c) =>
    c
      .query(
        `
      CREATE OR REPLACE FUNCTION ${schema}.get_${table}()
      RETURNS SETOF ${schema}.${table} LANGUAGE plpgsql AS $$
      BEGIN
        -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
        RETURN QUERY SELECT * FROM ${schema}.${table};
      END; $$;
      COMMENT ON FUNCTION ${schema}.get_${table}() IS 'automatic_get_api';
    `,
      )
      .then(() => true),
  )

export async function createMethodGetRecordsByKey(schema, table, indexParamsColumns) {
  const cols = Array.isArray(indexParamsColumns)
    ? indexParamsColumns
        .map(String)
        .map((c) => c.trim())
        .filter(Boolean)
    : String(indexParamsColumns ?? "")
        .split(",")
        .map((c) => c.trim())
        .filter(Boolean)

  if (!cols.length) throw new Error("indexParamsColumns must contain at least one column name")

  const camelToSnake = (s) => (s.includes("_") ? s : s.replace(/([A-Z])/g, "_$1").toLowerCase())
  const dbCols = cols.map(camelToSnake)

  return withClient(async (c) => {
    const { rows } = await c.query(
      `SELECT column_name, data_type, character_maximum_length
       FROM information_schema.columns
       WHERE table_schema=$1 AND table_name=$2 AND column_name=ANY($3::text[])`,
      [schema, table, dbCols],
    )

    const typeMap = Object.fromEntries(
      rows.map(({ column_name, data_type, character_maximum_length }) => [
        column_name,
        data_type === "character varying" && character_maximum_length
          ? `character varying(${character_maximum_length})`
          : data_type,
      ]),
    )

    const missing = dbCols.filter((c) => !typeMap[c])
    if (missing.length) throw new Error(`Columns not found in ${schema}.${table}: ${missing.join(", ")}`)

    const paramsDef = dbCols.map((c) => `p_${c} ${typeMap[c]}`).join(", ")
    const whereClause = dbCols.map((c) => `"${c}" = p_${c}`).join(" AND ")

    await c.query(`
      CREATE OR REPLACE FUNCTION ${schema}.get_${table}_by_key(${paramsDef})
      RETURNS SETOF ${schema}.${table} LANGUAGE plpgsql AS $$
      BEGIN
        -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
        RETURN QUERY SELECT * FROM ${schema}.${table} WHERE ${whereClause};
      END; $$;
      COMMENT ON FUNCTION ${schema}.get_${table}_by_key(${paramsDef}) IS 'automatic_get_api';
    `)
    return true
  })
}
