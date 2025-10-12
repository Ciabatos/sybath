import dotenv from "dotenv"
import path from "path"
import { Client } from "pg"

dotenv.config({ path: path.resolve(process.cwd(), ".env.development") })

const typeMap = {
  integer: "number",
  bigint: "number",
  smallint: "number",
  numeric: "number",
  decimal: "number",
  "double precision": "number",
  real: "number",
  serial: "number",
  bigserial: "number",
  boolean: "boolean",
  text: "string",
  "character varying": "string",
  character: "string",
  varchar: "string",
  date: "string",
  timestamp: "string",
  "timestamp without time zone": "string",
  "timestamp with time zone": "string",
  timestamptz: "string",
  time: "string",
  json: "any",
  jsonb: "any",
  uuid: "string",
  bytea: "Buffer",
}

// Mapowanie SQL -> TS typ
function mapSQLTypeToTS(sqlType) {
  if (!sqlType) return "any"

  let cleanType = sqlType.trim().toLowerCase()

  // Obsługa array types, np. "integer[]" -> "number[]"
  if (cleanType.endsWith("[]")) {
    const baseType = cleanType.slice(0, -2).replace(/\([^)]*\)/g, "")
    const baseTsType = typeMap[baseType] || "any"
    return `${baseTsType}[]`
  }

  // Usuń długości i parametry typu, np. "varchar(255)" -> "varchar"
  cleanType = cleanType.replace(/\([^)]*\)/g, "")

  return typeMap[cleanType] || "any"
}

// Pobranie listy schematów
async function fetchSchemas() {
  const client = new Client({
    host: process.env.PG_MAIN_HOST,
    user: process.env.PG_MAIN_USER,
    password: process.env.PG_MAIN_PASSWORD || "",
    database: process.env.PG_MAIN_DATABASE,
    port: process.env.PG_MAIN_PORT ? Number(process.env.PG_MAIN_PORT) : undefined,
  })
  await client.connect()
  try {
    const res = await client.query(
      `SELECT schema_name
       FROM information_schema.schemata
       WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
       ORDER BY schema_name`,
    )
    return res.rows.map((r) => r.schema_name)
  } finally {
    await client.end()
  }
}

// Pobranie listy procedur w schemacie
async function fetchMethods(schema) {
  const client = new Client({
    host: process.env.PG_MAIN_HOST,
    user: process.env.PG_MAIN_USER,
    password: process.env.PG_MAIN_PASSWORD || "",
    database: process.env.PG_MAIN_DATABASE,
    port: process.env.PG_MAIN_PORT ? Number(process.env.PG_MAIN_PORT) : undefined,
  })
  await client.connect()
  try {
    const res = await client.query(
      `SELECT proname
       FROM pg_proc p
       JOIN pg_namespace n ON p.pronamespace = n.oid
       WHERE n.nspname = $1
       AND p.prokind = 'f'
       ORDER BY proname`,
      [schema],
    )
    return res.rows.map((r) => r.proname)
  } finally {
    await client.end()
  }
}

// Pobranie parametrów procedury
async function fetchMethodArgs(schema, method) {
  const client = new Client({
    host: process.env.PG_MAIN_HOST,
    user: process.env.PG_MAIN_USER,
    password: process.env.PG_MAIN_PASSWORD || "",
    database: process.env.PG_MAIN_DATABASE,
    port: process.env.PG_MAIN_PORT ? Number(process.env.PG_MAIN_PORT) : undefined,
  })
  await client.connect()
  try {
    const res = await client.query(
      `SELECT pg_get_function_arguments(p.oid) AS args
       FROM pg_proc p
       JOIN pg_namespace n ON p.pronamespace = n.oid
       WHERE n.nspname = $1 AND p.proname = $2`,
      [schema, method],
    )
    if (!res.rows[0]) throw new Error(`Function ${schema}.${method} not found`)
    return res.rows[0].args || ""
  } finally {
    await client.end()
  }
}

// Pobranie kolumn zwracanych przez funkcję TABLE
async function fetchMethodResultColumns(schema, method) {
  const client = new Client({
    host: process.env.PG_MAIN_HOST,
    user: process.env.PG_MAIN_USER,
    password: process.env.PG_MAIN_PASSWORD || "",
    database: process.env.PG_MAIN_DATABASE,
    port: process.env.PG_MAIN_PORT ? Number(process.env.PG_MAIN_PORT) : undefined,
  })
  await client.connect()
  try {
    // Najpierw pobierz typ zwracany
    const resultTypeRes = await client.query(
      `SELECT pg_get_function_result(p.oid) AS result
       FROM pg_proc p
       JOIN pg_namespace n ON p.pronamespace = n.oid
       WHERE n.nspname = $1 AND p.proname = $2`,
      [schema, method],
    )

    if (!resultTypeRes.rows[0]) {
      throw new Error(`Function ${schema}.${method} not found`)
    }

    const resultType = resultTypeRes.rows[0].result

    // Sprawdź czy to TABLE type
    if (!resultType.startsWith("TABLE(")) {
      // Jeśli nie jest TABLE, zwróć prosty typ
      return [{ name: "result", type: mapSQLTypeToTS(resultType) }]
    }

    // Wyciągnij nazwę composite type z TABLE(...)
    const tableMatch = resultType.match(/TABLE\((.*?)\)/)
    if (!tableMatch) {
      return [{ name: "result", type: "any" }]
    }

    // Parsuj kolumny bezpośrednio z definicji TABLE
    const columnsStr = tableMatch[1]
    const columns = columnsStr
      .split(",")
      .map((col) => {
        const trimmed = col.trim()
        const spaceIndex = trimmed.indexOf(" ")
        if (spaceIndex === -1) return null

        const name = trimmed.substring(0, spaceIndex)
        const type = trimmed.substring(spaceIndex + 1)

        return { name, type: mapSQLTypeToTS(type) }
      })
      .filter(Boolean)

    return columns
  } finally {
    await client.end()
  }
}

// Parser do sygnatury TS
function parseArgsToList(argsStr) {
  if (!argsStr) return ""

  return argsStr
    .split(",")
    .map((arg) => {
      const trimmed = arg.trim()
      const spaceIndex = trimmed.indexOf(" ")
      if (spaceIndex === -1) return null

      const name = trimmed.substring(0, spaceIndex)
      const type = trimmed.substring(spaceIndex + 1)

      return `${name}: ${mapSQLTypeToTS(type)}`
    })
    .filter(Boolean)
    .join(", ")
}

// Pobierz nazwy argumentów
function getArgsArray(argsStr) {
  if (!argsStr) return []

  return argsStr
    .split(",")
    .map((arg) => {
      const trimmed = arg.trim()
      const spaceIndex = trimmed.indexOf(" ")
      return spaceIndex === -1 ? trimmed : trimmed.substring(0, spaceIndex)
    })
    .filter(Boolean)
}

// Generator plop
export default function getMethod(plop) {
  plop.setGenerator("Get Function", {
    description: "Generate TS async function from Postgres method",

    prompts: async (inquirer) => {
      const schemas = await fetchSchemas()

      if (schemas.length === 0) {
        throw new Error("Brak dostępnych schematów")
      }

      const { schema } = await inquirer.prompt([
        {
          type: "list",
          name: "schema",
          message: "Wybierz schemat:",
          choices: schemas,
        },
      ])

      const methods = await fetchMethods(schema)

      if (methods.length === 0) {
        throw new Error(`Brak procedur w schemacie: ${schema}`)
      }

      const { method } = await inquirer.prompt([
        {
          type: "list",
          name: "method",
          message: "Wybierz procedurę:",
          choices: methods,
        },
      ])

      const argsStr = await fetchMethodArgs(schema, method)
      const resultColumns = await fetchMethodResultColumns(schema, method)

      const tsArgsList = parseArgsToList(argsStr)
      const argsArray = getArgsArray(argsStr)
      const sqlParamsPlaceholders = argsArray.map((_, i) => `$${i + 1}`).join(", ")
      const methodPascalName = method.replace(/(^|_)([a-z])/g, (_, __, c) => c.toUpperCase())
      const methodCamelName = method.replace(/_([a-z])/g, (_, c) => c.toUpperCase())

      const tsReturnType = `export type T${methodPascalName} = {\n${resultColumns.map((c) => `  ${c.name}: ${c.type}`).join("\n")}\n}`

      return {
        schema,
        method,
        methodPascalName,
        methodCamelName,
        tsArgsList,
        argsArray: argsArray.join(", "),
        sqlParamsPlaceholders,
        tsReturnType,
      }
    },

    actions: [
      {
        type: "add",
        path: "db/postgresMainDatabase/schemas/{{schema}}/{{methodCamelName}}.tsx",
        templateFile: "plop-templates/dbGetFunction.hbs",
        force: true,
      },
    ],
  })
}
