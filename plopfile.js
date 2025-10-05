import dotenv from "dotenv"
import path from "path"
import { Client } from "pg"

dotenv.config({ path: path.resolve(process.cwd(), ".env.development") })

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

export default function plopfile(plop) {
  plop.setHelper("eq", (a, b) => a === b)
  plop.setGenerator("Get Table", {
    description: "Generate TypeScript types and fetcher from Postgres table",
    prompts: async (inquirer) => {
      //  Zapytaj o schema i table
      const { schema, table } = await inquirer.prompt([
        {
          type: "input",
          name: "schema",
          message: "Postgres schema:",
        },
        {
          type: "input",
          name: "table",
          message: "Table name:",
        },
      ])

      //  Pobierz kolumny z bazy
      const rows = await fetchColumns(schema, table)

      if (rows.length === 0) {
        throw new Error(`No columns found for ${schema}.${table}`)
      }

      //  Konwersja typów SQL → TypeScript
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

      const fields = rows.map((col) => ({
        name: col.column_name,
        tsType: typeMap[col.data_type] || "any",
        optional: col.is_nullable === "YES" ? "?" : "",
      }))

      //  Zapytaj użytkownika o wybór kolumn
      const { selectedColumnsIndex } = await inquirer.prompt([
        {
          type: "checkbox",
          name: "selectedColumnsIndex",
          message: "Wybierz kolumny dla indexu",
          choices: fields.map((f) => ({
            name: `${f.name} (${f.tsType})`,
            value: f.name,
            checked: false, // domyślnie wszystkie zaznaczone
          })),
        },
      ])

      //  Filtruj tylko wybrane kolumny
      const indexFields = fields.filter((f) => selectedColumnsIndex.includes(f.name))

      //  Formatuj nazwy
      indexFields.forEach((f) => {
        f.pascalName = f.name.replace(/(^|_)([a-z])/g, (_, __, c) => c.toUpperCase())
      })

      const typeRecordName = indexFields.map((f) => f.pascalName).join("")

      const tablePascalName = table.replace(/(^|_)([a-z])/g, (_, __, c) => c.toUpperCase())
      const typeName = "T" + tablePascalName
      const methodName = schema.replace(/(^|_)([a-z])/g, (_, __, c) => c.toUpperCase()) + tablePascalName

      const indexMethodName = indexFields.length > 1 ? "arrayToObjectKeysId" : "arrayToObjectKeyId"
      const indexMethodArgs =
        indexMethodName === "arrayToObjectKeysId"
          ? indexFields.map((f) => `"${f.name}"`).join(", ") // "id", "name"
          : indexFields[0].name // id

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
      })

      //  Zwróć wszystkie dane jako answers
      return {
        schema,
        table,
        tablePascalName,
        typeName,
        typeRecordName,
        methodName,
        indexFields,
        fields,
        indexMethodName,
        indexMethodArgs,
      }
    },

    // 🎯 ACTIONS - mają dostęp do danych z prompts
    actions: [
      {
        type: "add",
        path: "db/postgresMainDatabase/schemas/{{schema}}/{{table}}.tsx",
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
    ],
  })
}
