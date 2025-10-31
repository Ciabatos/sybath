import dotenv from "dotenv"
import path from "path"
import { mapSQLTypeToTS, snakeToCamel, snakeToPascal } from "./helpers/helpers.js"
import { fetchColumns, fetchSchemas, fetchTables } from "./helpers/queries.js"

dotenv.config({ path: path.resolve(process.cwd(), ".env.development") })

// Konwersja typów SQL → TypeScript

export default function getTable(plop) {
  plop.setGenerator("Get Table", {
    description: "Generate from Postgres table",

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

      const methodColumns = rows.map((col) => ({
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
          choices: methodColumns.map((f) => ({
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
      const indexColumns = methodColumns.filter((f) => selectedColumnsIndex.includes(f.name))

      // Formatuj nazwy
      indexColumns.forEach((f) => {
        f.pascalName = snakeToPascal(f.name)
      })

      // Wybór kolumn jako parametry funkcji
      const { paramsColumns } = await inquirer.prompt([
        {
          type: "checkbox",
          name: "paramsColumns",
          message: "Wybierz kolumny jako parametry funkcji (opcjonalnie):",
          choices: methodColumns.map((f) => ({
            name: `${f.name} (${f.tsType})`,
            value: f.name,
          })),
        },
      ])

      const methodParamsColumns = methodColumns
        .filter((f) => paramsColumns.includes(f.name))
        .map((f) => ({
          name: f.name,
          camelName: f.camelName,
          tsType: f.tsType,
        }))

      const tablePascalName = snakeToPascal(table)
      const tableCamelName = snakeToCamel(table)
      const methodTypeName = "T" + snakeToPascal(schema) + tablePascalName
      const methodParamsTypeName = methodTypeName + "Params"
      const methodName = "get" + snakeToPascal(schema) + tablePascalName

      const indexTypeMethodName = indexColumns.map((f) => f.pascalName).join("")
      const indexMethodName = indexColumns.length > 1 ? "arrayToObjectKeysId" : "arrayToObjectKeyId"
      const indexTypeName = methodTypeName + "RecordBy" + indexTypeMethodName
      const indexMethodParams = indexColumns.map((f) => `"${snakeToCamel(f.name)}"`).join(", ")
      const indexParamsColumns = methodParamsColumns.map((f) => snakeToCamel(f.name)).join(", ")

      console.log({
        schema,
        table,
        tableCamelName,
        tablePascalName,
        methodTypeName,
        methodParamsTypeName,
        methodParamsColumns,
        methodName,
        methodColumns,
        indexMethodParams,
        indexParamsColumns,
        indexTypeMethodName,
        indexMethodName,
        indexTypeName,
        indexColumns,
      })

      return {
        schema,
        table,
        tableCamelName,
        tablePascalName,
        methodTypeName,
        methodParamsTypeName,
        methodParamsColumns,
        methodName,
        methodColumns,
        indexMethodParams,
        indexParamsColumns,
        indexTypeMethodName,
        indexMethodName,
        indexTypeName,
        indexColumns,
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
        path: "app/api/{{tableCamelName}}/route.tsx",
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
        template: `$&import { {{indexTypeName}} } from "@/db/postgresMainDatabase/schemas/{{schema}}/{{tableCamelName}}"\n`,
      },
      {
        type: "modify",
        path: "store/atoms.ts",
        pattern: /(\/\/Tables\s*\n)/,
        template: `$1export const {{tableCamelName}}Atom = atom<{{indexTypeName}}>({})\n`,
      },
    ],
  })
}
