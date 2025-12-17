import dotenv from "dotenv"
import path from "path"
import { camelToKebab, getArgsArray, mapSQLTypeToTS, snakeToCamel, snakeToPascal } from "./helpers/helpers.js"
import {
  createMethodGetRecords,
  createMethodGetRecordsByKey,
  fetchColumns,
  fetchMethodArgs,
  fetchSchemas,
  fetchTables,
} from "./helpers/queries.js"
dotenv.config({ path: path.resolve(process.cwd(), ".env.development") })

// Konwersja typów SQL → TypeScript

export default function getTable(plop) {
  plop.setGenerator("Get Data From Table", {
    description: "Generate fetchers from Postgres table",

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
          message: "Wybierz kolumny dla indexu do szybkiego wyszukiwania krotki:",
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
          message: "Wybierz kolumny jako parametry WHERE dla jednego rekordu:",
          choices: methodColumns.map((f) => ({
            name: `${f.name} (${f.tsType})`,
            value: f.name,
          })),
          validate: (answer) => {
            if (answer.length < 1) {
              return "Musisz zaznaczyć przynajmniej jedną kolumnę."
            }
            return true
          },
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
      const schemaTablePascalName = snakeToPascal(schema) + tablePascalName
      const methodTypeName = "T" + schemaTablePascalName
      const methodParamsTypeName = methodTypeName + "Params"
      const methodName = "get" + schemaTablePascalName
      const methodNameByKey = "get" + schemaTablePascalName + "ByKey"

      const indexTypeMethodName = indexColumns.map((f) => f.pascalName).join("")
      const indexMethodName = "arrayToObjectKey"
      const indexTypeName = methodTypeName + "RecordBy" + indexTypeMethodName
      const indexMethodParams = `[${indexColumns.map((f) => `"${snakeToCamel(f.name)}"`).join(", ")}]`
      const indexParamsColumns = methodParamsColumns.map((f) => snakeToCamel(f.name)).join(", ")

      await createMethodGetRecords(schema, table)
      await createMethodGetRecordsByKey(schema, table, indexParamsColumns)

      const methodRecords = `get_${table}`
      const methodRecordsByKey = `get_${table}_by_key`

      const argsStr = await fetchMethodArgs(schema, methodRecordsByKey)
      const argsArray = getArgsArray(argsStr)
      const sqlParamsPlaceholders = argsArray.map((_, i) => `$${i + 1}`).join(", ")

      const apiParamPathSquareBrackets = methodParamsColumns.length
        ? "/" + methodParamsColumns.map((f) => `[${f.camelName}]`).join("/")
        : ""
      const apiParamPath = methodParamsColumns.length
        ? "/" + methodParamsColumns.map((f) => `\${params.${f.camelName}}`).join("/")
        : ""

      const tableKebabName = camelToKebab(tableCamelName)
      const apiPath = `app/api/${schema}/${tableKebabName}/route.ts`
      const apiPathByKey = `app/api/${schema}/${tableKebabName}${apiParamPathSquareBrackets}/route.ts`
      const apiPathParams = `/api/${schema}/${tableKebabName}`
      const apiPathParamsByKey = `/api/${schema}/${tableKebabName}${apiParamPath}`

      const { generateMutation } = await inquirer.prompt([
        {
          type: "list",
          name: "generateMutation",
          message:
            "Czy chcesz wygenerować także hook useMutate ? Służy do szybkiego odświeżania UI po użyciu akcji, ale należy dokonać ręcznej konfiguracji",
          choices: [
            { name: "Nie", value: false },
            { name: "Tak", value: true },
          ],
        },
      ])

      const { mutationMergeOldData } = await inquirer.prompt([
        {
          type: "list",
          name: "mutationMergeOldData",
          message: "Czy zmergować stare dane z atomu do nowych danych przy użyciu Mutate ?",
          choices: [
            { name: "Nie", value: false },
            { name: "Tak", value: true },
          ],
          when: () => generateMutation === true,
        },
      ])

      console.log({
        schema,
        table,
        tableCamelName,
        tablePascalName,
        tableKebabName,
        schemaTablePascalName,
        methodTypeName,
        methodParamsTypeName,
        methodParamsColumns,
        methodName,
        methodNameByKey,
        methodRecords,
        methodRecordsByKey,
        sqlParamsPlaceholders,
        methodColumns,
        indexMethodParams,
        indexParamsColumns,
        indexTypeMethodName,
        indexMethodName,
        indexTypeName,
        indexColumns,
        apiPath,
        apiPathParams,
        apiPathByKey,
        apiPathParamsByKey,
        generateMutation,
        mutationMergeOldData,
      })

      return {
        schema,
        table,
        tableCamelName,
        tablePascalName,
        tableKebabName,
        schemaTablePascalName,
        methodTypeName,
        methodParamsTypeName,
        methodParamsColumns,
        methodName,
        methodNameByKey,
        methodRecords,
        methodRecordsByKey,
        sqlParamsPlaceholders,
        methodColumns,
        indexMethodParams,
        indexParamsColumns,
        indexTypeMethodName,
        indexMethodName,
        indexTypeName,
        indexColumns,
        apiPath,
        apiPathParams,
        apiPathByKey,
        apiPathParamsByKey,
        generateMutation,
        mutationMergeOldData,
      }
    },

    actions: [
      {
        type: "add",
        path: "db/postgresMainDatabase/schemas/{{schema}}/{{tableCamelName}}.ts",
        templateFile: "plop-templates/dbGetTable.hbs",
        force: true,
      },
      {
        type: "add",
        path: "{{apiPath}}",
        templateFile: "plop-templates/apiGetTable.hbs",
        force: true,
      },
      {
        type: "add",
        path: "{{apiPathByKey}}",
        templateFile: "plop-templates/apiGetTableByKey.hbs",
        force: true,
      },
      {
        type: "add",
        path: "methods/hooks/{{schema}}/core/useFetch{{schemaTablePascalName}}.ts",
        templateFile: "plop-templates/hookGetTable.hbs",
        force: true,
      },
      {
        type: "add",
        path: "methods/hooks/{{schema}}/core/useFetch{{schemaTablePascalName}}ByKey.ts",
        templateFile: "plop-templates/hookGetTableByKey.hbs",
        force: true,
      },
      {
        type: "add",
        path: "methods/server-fetchers/{{schema}}/core/get{{schemaTablePascalName}}Server.ts",
        templateFile: "plop-templates/hookGetTableServer.hbs",
        force: true,
      },
      {
        type: "add",
        path: "methods/server-fetchers/{{schema}}/core/get{{schemaTablePascalName}}ByKeyServer.ts",
        templateFile: "plop-templates/hookGetTableByKeyServer.hbs",
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
      {
        type: "modify",
        path: ".vscode/snippets.code-snippets",
        pattern: /(?=\/\/Automatic Snippets\s*\n)/,
        templateFile: "plop-templates/snippetHookTable.hbs",
      },
      {
        type: "modify",
        path: ".vscode/snippets.code-snippets",
        pattern: /(?=\/\/Automatic Snippets\s*\n)/,
        templateFile: "plop-templates/snippetHookTableByKey.hbs",
      },
      {
        type: "add",
        path: "methods/hooks/{{schema}}/core/useMutate{{schemaTablePascalName}}.ts",
        templateFile: "plop-templates/hookMutateTable.hbs",
        force: true,
        skip(answers) {
          return answers.generateMutation ? false : "Pomijam generowanie useMutate..."
        },
      },
      {
        type: "PrettierFormat",
      },
    ],
  })
}
