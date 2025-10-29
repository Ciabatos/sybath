import dotenv from "dotenv"
import path from "path"
import { Client } from "pg"

dotenv.config({ path: path.resolve(process.cwd(), ".env.development") })

// Konwersja typów SQL → TypeScript
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

// Konwersja snake_case -> camelCase
function snakeToCamel(str) {
  return str.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase())
}

// Konwersja snake_case -> PascalCase
function snakeToPascal(str) {
  return str.replace(/(^|_)([a-z])/g, (_, __, c) => c.toUpperCase())
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
    password: process.env.PG_MAIN_PASSWORD ?? "",
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

// Pobranie listy tabel w schemacie
async function fetchTables(schema) {
  const client = new Client({
    host: process.env.PG_MAIN_HOST,
    user: process.env.PG_MAIN_USER,
    password: process.env.PG_MAIN_PASSWORD ?? "",
    database: process.env.PG_MAIN_DATABASE,
    port: process.env.PG_MAIN_PORT ? Number(process.env.PG_MAIN_PORT) : undefined,
  })
  await client.connect()
  try {
    const res = await client.query(
      `SELECT table_name
       FROM information_schema.tables
       WHERE table_schema = $1 AND table_type = 'BASE TABLE'
       ORDER BY table_name`,
      [schema],
    )
    return res.rows.map((r) => r.table_name)
  } finally {
    await client.end()
  }
}

// Pobranie kolumn tabeli
async function fetchColumns(schema, table) {
  if (!table) throw new Error("Table name is required for fetchColumns")
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
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_schema = $1 AND table_name = $2
      ORDER BY ordinal_position
    `
    const res = await client.query(sql, [schema, table])
    return res.rows
  } finally {
    try {
      await client.end()
    } catch {}
  }
}

export default function getTable(plop) {
  plop.setGenerator("Get Table", {
    description: "Generate TypeScript types and fetcher from Postgres table",

    prompts: async (inquirer) => {
      // Pobranie schematów
      const schemas = await fetchSchemas()

      if (schemas.length === 0) {
        throw new Error("Brak dostępnych schematów")
      }

      // Wybór schematu
      const { schema } = await inquirer.prompt([
        {
          type: "list",
          name: "schema",
          message: "Wybierz schemat:",
          choices: schemas,
        },
      ])

      // Pobranie tabel w schemacie
      const tables = await fetchTables(schema)

      if (tables.length === 0) {
        throw new Error(`Brak tabel w schemacie: ${schema}`)
      }

      // Wybór tabeli
      const { table } = await inquirer.prompt([
        {
          type: "list",
          name: "table",
          message: "Wybierz tabelę:",
          choices: tables,
        },
      ])

      // Pobierz kolumny z bazy
      const rows = await fetchColumns(schema, table)

      if (rows.length === 0) {
        throw new Error(`Brak kolumn w tabeli ${schema}.${table}`)
      }

      const fields = rows.map((col) => ({
        name: col.column_name,
        camelName: snakeToCamel(col.column_name),
        tsType: mapSQLTypeToTS(col.data_type),
        optional: col.is_nullable === "YES" ? "?" : "",
      }))

      // Zapytaj użytkownika o wybór kolumn dla indexu
      const { selectedColumnsIndex } = await inquirer.prompt([
        {
          type: "checkbox",
          name: "selectedColumnsIndex",
          message: "Wybierz kolumny dla indexu:",
          choices: fields.map((f) => ({
            name: `${f.name} (${f.tsType})`,
            value: f.name,
            checked: false,
          })),
          validate: (answer) => {
            if (answer.length < 1) {
              return "Musisz zaznaczyć przynajmniej jedną kolumnę."
            }
            return true
          },
        },
      ])

      // Filtruj tylko wybrane kolumny
      const indexFields = fields.filter((f) => selectedColumnsIndex.includes(f.name))

      // Formatuj nazwy
      indexFields.forEach((f) => {
        f.pascalName = snakeToPascal(f.name)
      })

      // Wybór kolumn jako parametry funkcji
      const { paramsColumns } = await inquirer.prompt([
        {
          type: "checkbox",
          name: "paramsColumns",
          message: "Wybierz kolumny jako parametry funkcji (opcjonalnie):",
          choices: fields.map((f) => ({
            name: `${f.name} (${f.tsType})`,
            value: f.name,
          })),
        },
      ])

      const paramsFields = fields.filter((f) => paramsColumns.includes(f.name))

      const tablePascalName = snakeToPascal(table)
      const typeName = "T" + snakeToPascal(schema) + tablePascalName
      const typeRecordName = indexFields.map((f) => f.pascalName).join("")
      const methodName = snakeToPascal(schema) + tablePascalName

      const indexMethodName = indexFields.length > 1 ? "arrayToObjectKeysId" : "arrayToObjectKeyId"
      const indexMethodArgs = indexFields.map((f) => `"${snakeToCamel(f.name)}"`).join(", ")

      const paramsList = paramsFields.map((f) => snakeToCamel(f.name)).join(", ")

      console.log({
        schema,
        table,
        tablePascalName,
        typeName,
        methodName,
        typeRecordName,
        fields,
        indexFields,
        indexMethodName,
        indexMethodArgs,
        paramsFields,
        paramsList,
      })

      return {
        schema,
        table,
        tablePascalName,
        typeName,
        methodName,
        typeRecordName,
        fields,
        indexFields,
        indexMethodName,
        indexMethodArgs,
        paramsFields,
        paramsList,
      }
    },

    actions: [
      {
        type: "add",
        path: "db/postgresMainDatabase/schemas/{{schema}}/{{tablePascalName}}.tsx",
        templateFile: "plop-templates/dbGetTable.hbs",
        force: true,
      },
      {
        type: "add",
        path: "app/api/{{table}}/route.tsx",
        templateFile: "plop-templates/apiGetTable.hbs",
        force: true,
      },
      {
        type: "add",
        path: "methods/hooks/{{schema}}/core/useFetch{{tablePascalName}}.tsx",
        templateFile: "plop-templates/hookGetTable.hbs",
        force: true,
      },
      {
        type: "add",
        path: "methods/fetchers/{{schema}}/fetch{{tablePascalName}}Server.ts",
        templateFile: "plop-templates/hookGetTableServer.hbs",
        force: true,
      },
      {
        type: "modify",
        path: "store/atoms.ts",
        pattern: /((?:^"use client"\n)?(?:import[\s\S]*?\n))(?!import)/m,
        template: `$&import { {{typeName}}RecordBy{{typeRecordName}} } from "@/db/postgresMainDatabase/schemas/{{schema}}/{{table}}"\n`,
      },
      {
        type: "modify",
        path: "store/atoms.ts",
        pattern: /(\/\/Tables\s*\n)/,
        template: `$1export const {{table}}Atom = atom<{{typeName}}RecordBy{{typeRecordName}}>({})\n`,
      },
    ],
  })
}
