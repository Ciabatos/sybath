import dotenv from "dotenv"
import path from "path"
import { mapSQLTypeToTS, snakeToCamel, snakeToPascal } from "./helpers.js"
import { fetchColumns, fetchSchemas, fetchTables } from "./queries.js"

dotenv.config({ path: path.resolve(process.cwd(), ".env.development") })

// Konwersja typów SQL → TypeScript

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

      // paramsFields: DRY, bez helpers, tylko lokalne mapowanie
      const paramsFields = fields
        .filter((f) => paramsColumns.includes(f.name))
        .map((f) => ({
          name: f.name,
          camelName: f.camelName,
          tsType: f.tsType,
        }))

      const tablePascalName = snakeToPascal(table)
      const tableCamelName = snakeToCamel(table)
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
        tableCamelName,
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

      // Dodaj ujednolicone nazwy dla return
      const name = table
      const camelName = snakeToCamel(table)
      const pascalName = snakeToPascal(table)

      return {
        schema,
        table: name,
        tableCamelName: camelName,
        tablePascalName: pascalName,
        name,
        camelName,
        pascalName,
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
        path: "db/postgresMainDatabase/schemas/{{schema}}/{{tableCamelName}}.tsx",
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
        template: `$&import { {{typeName}}RecordBy{{typeRecordName}} } from "@/db/postgresMainDatabase/schemas/{{schema}}/{{tableCamelName}}"\n`,
      },
      {
        type: "modify",
        path: "store/atoms.ts",
        pattern: /(\/\/Tables\s*\n)/,
        template: `$1export const {{tableCamelName}}Atom = atom<{{typeName}}RecordBy{{typeRecordName}}>({})\n`,
      },
    ],
  })
}
