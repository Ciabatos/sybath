import { Client } from "pg"
import path from "path"
import dotenv from "dotenv"

dotenv.config({ path: path.resolve(process.cwd(), ".env.development") })

// Mapowanie typów SQL -> TS
const typeMap = {
  integer: "number",
  bigint: "number",
  smallint: "number",
  numeric: "number",
  double: "number",
  real: "number",
  serial: "number",
  bigserial: "number",
  boolean: "boolean",
  text: "string",
  varchar: "string",
  "character varying": "string",
  date: "string",
  timestamp: "string",
  "timestamp without time zone": "string",
  "timestamp with time zone": "string",
  json: "any",
  jsonb: "any",
  uuid: "string",
}

// Pobranie parametrów i typu zwracanego procedury
async function fetchProcedureMeta(schema, procedure) {
  const client = new Client({
    host: process.env.PG_MAIN_HOST,
    user: process.env.PG_MAIN_USER,
    password: process.env.PG_MAIN_PASSWORD ?? "",
    database: process.env.PG_MAIN_DATABASE,
    port: process.env.PG_MAIN_PORT ? Number(process.env.PG_MAIN_PORT) : undefined,
  })

  try {
    await client.connect()

    const sql = `
      SELECT
        pg_get_function_arguments(p.oid) AS arguments,
        pg_get_function_result(p.oid) AS result
      FROM pg_proc p
      JOIN pg_namespace n ON p.pronamespace = n.oid
      WHERE n.nspname = $1 AND p.proname = $2
    `

    const res = await client.query(sql, [schema, procedure])
    if (!res.rows[0]) throw new Error(`Function ${schema}.${procedure} not found`)
    return res.rows[0]
  } finally {
    try { await client.end() } catch {}
  }
}

// Parser argumentów na TS type
function parseArgsToTS(argsStr) {
  if (!argsStr) return "void"
  const args = argsStr.split(",").map((a) => {
    const [name, type] = a.trim().split(/\s+/)
    const tsType = typeMap[type] || "any"
    return `${name}: ${tsType}`
  })
  return `{ ${args.join("; ")} }`
}

// Parser typu zwracanego na TS type
function parseResultToTS(resultStr, typeName) {
  const match = resultStr.match(/TABLE\((.*)\)/i)
  if (!match) return "any"

  const columns = match[1].split(",").map((c) => {
    const [name, type] = c.trim().split(/\s+/)
    const tsType = typeMap[type] || "any"
    return `${name}: ${tsType}`
  })
  return `export type ${typeName} = {\n  ${columns.join("\n  ")}\n}`
}


// Zwraca string do użycia w sygnaturze funkcji TS: "arg1: number, arg2: string"
function parseArgsToTSList(argsStr) {
  if (!argsStr) return ""
  return argsStr
    .split(",")
    .map((a) => {
      const [name, type] = a.trim().split(/\s+/)
      const tsType = typeMap[type] || "any"
      return `${name}: ${tsType}`
    })
    .join(", ")
}

// Zwraca tablicę nazw argumentów do przekazania do query: "[arg1, arg2]"
function getArgsArray(argsStr) {
  if (!argsStr) return "[]"
  const args = argsStr
    .split(",")
    .map((a) => a.trim().split(/\s+/)[0]) // tylko nazwa argumentu
  return `[${args.join(", ")}]`
}


export default function addProcedure(plop) {
  plop.setGenerator("Get Procedure", {
    description: "Generate TS types and async function from Postgres procedure",

    prompts: async (inquirer) => {
      const { schema, procedure } = await inquirer.prompt([
        {
          type: "input",
          name: "schema",
          message: "Procedure schema:",
          filter: (val) => val.toLowerCase(),
        },
        {
          type: "input",
          name: "procedure",
          message: "Procedure name:",
          filter: (val) => val.toLowerCase(),
        },
      ])

      const meta = await fetchProcedureMeta(schema, procedure)

      const tsArgsType = parseArgsToTS(meta.arguments)
      const procedurePascalName = procedure.replace(/(^|_)([a-z])/g, (_, __, c) => c.toUpperCase())
      const tsReturnType = parseResultToTS(meta.result, `T${procedurePascalName}Result`)
      const tsArgsList = parseArgsToTSList(meta.arguments)
      const argsArray = getArgsArray(meta.arguments)
      
      return {
        schema,
        procedure,
        procedurePascalName,
        tsArgsType,
        tsReturnType,
        tsArgsList,
        argsArray,
      }
    },

    actions: [
      {
        type: "add",
        path: "db/postgresMainDatabase/procedures/{{schema}}/{{procedure}}.ts",
        templateFile: "plop-templates/procedure.ts.hbs",
        force: true,
      },
    ],
  })
}
