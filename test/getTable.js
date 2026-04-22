import dotenv from "dotenv"
import fs from "fs"
import path from "path"
import { camelToKebab, mapSQLTypeToTS, snakeToCamel, snakeToPascal } from "./helpers/helpers.js"
import {
  createMethodGetRecords,
  createMethodGetRecordsByKey,
  fetchColumns,
  fetchMethodArgs,
  fetchSchemas,
  fetchTables,
} from "./helpers/queries.js"

dotenv.config({ path: path.resolve(process.cwd(), ".env.development") })

// ─── History helpers ──────────────────────────────────────────────────────────

function historyPath(generatorName, schema, key) {
  const dir = path.resolve(process.cwd(), `plop-generators/answerHistory/${generatorName}`)
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true })
  return path.join(dir, `${schema}_${key}_answers.json`)
}

async function loadPreviousAnswers(inquirer, historyFile, label) {
  if (!fs.existsSync(historyFile)) return null
  const { usePrevious } = await inquirer.prompt([
    {
      type: "list",
      name: "usePrevious",
      message: `Znaleziono zapisane ustawienia plop.js dla ${label}. Czy wczytać poprzednie ustawienia?`,
      choices: [
        { name: "Tak", value: true },
        { name: "Nie", value: false },
      ],
    },
  ])
  const saved = JSON.parse(fs.readFileSync(historyFile, "utf-8"))
  if (usePrevious) {
    console.log("Wczytano poprzednie ustawienia:", saved)
    return saved
  }
  return null
}

// ─── Generator ────────────────────────────────────────────────────────────────

export default function getTable(plop) {
  plop.setGenerator("getTable", {
    description: "Generate fetchers from Postgres table",

    prompts: async (inquirer) => {
      // 1. Schema
      const schemas = await fetchSchemas()
      if (!schemas.length) throw new Error("Brak dostępnych schematów")
      const { schema } = await inquirer.prompt([
        { type: "list", name: "schema", message: "Wybierz schemat:", choices: schemas },
      ])

      // 2. Table
      const tables = await fetchTables(schema)
      if (!tables.length) throw new Error(`Brak tabel w schemacie: ${schema}`)
      const { table } = await inquirer.prompt([
        { type: "list", name: "table", message: "Wybierz tabelę:", choices: tables },
      ])

      // 3. History
      const historyFile = historyPath("getTable", schema, table)
      const prev = await loadPreviousAnswers(inquirer, historyFile, `${schema}.${table}`)
      if (prev) return prev

      // 4. Columns
      const rows = await fetchColumns(schema, table)
      if (!rows.length) throw new Error(`Brak kolumn w tabeli ${schema}.${table}`)

      const methodColumns = rows.map(({ column_name, data_type, is_nullable }) => ({
        name: column_name,
        camelName: snakeToCamel(column_name),
        tsType: mapSQLTypeToTS(data_type),
        optional: is_nullable === "YES" ? "?" : "",
      }))

      // 5. Index columns
      const { selectedColumnsIndex } = await inquirer.prompt([
        {
          type: "checkbox",
          name: "selectedColumnsIndex",
          message: "Wybierz kolumny dla indexu do szybkiego wyszukiwania krotki po stronie Aplikacji:",
          default: null,
          choices: methodColumns.map((f) => ({ name: `${f.name} (${f.tsType})`, value: f.name, checked: false })),
          validate: (a) => a.length >= 1 || "Musisz zaznaczyć przynajmniej jedną kolumnę.",
        },
      ])

      const indexColumns = methodColumns
        .filter((f) => selectedColumnsIndex.includes(f.name))
        .map((f) => ({ ...f, pascalName: snakeToPascal(f.name) }))

      // 6. Param columns
      const { paramsColumns } = await inquirer.prompt([
        {
          type: "checkbox",
          name: "paramsColumns",
          message:
            "Wybierz parametry dla zbieranych rekordów po stronie SERWERA (przykład dla parametru mapId zbierz wszystkie mapTiles):",
          default: null,
          choices: methodColumns.map((f) => ({ name: `${f.name} (${f.tsType})`, value: f.name })),
          validate: (a) => a.length >= 1 || "Musisz zaznaczyć przynajmniej jedną kolumnę.",
        },
      ])

      const methodParamsColumns = methodColumns
        .filter((f) => paramsColumns.includes(f.name))
        .map(({ name, camelName, tsType }) => ({ name, camelName, tsType }))

      // 7. Derived names
      const tablePascalName = snakeToPascal(table)
      const tableCamelName = snakeToCamel(table)
      const schemaTablePascalName = snakeToPascal(schema) + tablePascalName
      const methodTypeName = `T${schemaTablePascalName}`
      const indexTypeMethodName = indexColumns.map((f) => f.pascalName).join("")
      const indexParamsColumns = methodParamsColumns.map((f) => snakeToCamel(f.name)).join(", ")
      const indexTypeName = `${methodTypeName}RecordBy${indexTypeMethodName}`
      const indexMethodParams = `[${indexColumns.map((f) => `"${snakeToCamel(f.name)}"`).join(", ")}]`
      const tableKebabName = camelToKebab(tableCamelName)

      // 8. Create DB functions
      await createMethodGetRecords(schema, table)
      await createMethodGetRecordsByKey(schema, table, indexParamsColumns)

      const methodRecords = `get_${table}`
      const methodRecordsByKey = `get_${table}_by_key`
      const { argsArray } = await fetchMethodArgs(schema, methodRecordsByKey)
      const sqlParamsPlaceholders = argsArray.map((_, i) => `$${i + 1}`).join(", ")

      const apiParamPathSquareBrackets = methodParamsColumns.length
        ? "/" + methodParamsColumns.map((f) => `[${f.camelName}]`).join("/")
        : ""
      const apiParamPath = methodParamsColumns.length
        ? "/" + methodParamsColumns.map((f) => `\${params.${f.camelName}}`).join("/")
        : ""
      const apiPath = `app/api/${schema}/${tableKebabName}/route.ts`
      const apiPathByKey = `app/api/${schema}/${tableKebabName}${apiParamPathSquareBrackets}/route.ts`
      const apiPathParams = `/api/${schema}/${tableKebabName}`
      const apiPathParamsByKey = `/api/${schema}/${tableKebabName}${apiParamPath}`

      const fetcherName = `fetch${schemaTablePascalName}`
      const fetcherNameByKey = `fetch${schemaTablePascalName}ByKey`

      // 9. Mutation prompts
      const { generateMutation } = await inquirer.prompt([
        {
          type: "list",
          name: "generateMutation",
          message: "Czy chcesz wygenerować także hook useMutate ? Służy do szybkiego odświeżania UI po użyciu akcji",
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
          when: () => generateMutation,
        },
      ])

      const result = {
        promptAnswers: {
          schema,
          table,
          usePrevious: false,
          selectedColumnsIndex,
          paramsColumns,
          generateMutation,
          mutationMergeOldData,
        },
        schema,
        table,
        tableCamelName,
        tablePascalName,
        tableKebabName,
        schemaTablePascalName,
        methodTypeName,
        methodParamsTypeName: `${methodTypeName}Params`,
        methodParamsColumns,
        methodColumns,
        methodName: `get${schemaTablePascalName}`,
        methodNameByKey: `get${schemaTablePascalName}ByKey`,
        methodRecords,
        methodRecordsByKey,
        sqlParamsPlaceholders,
        indexMethodParams,
        indexParamsColumns,
        indexTypeMethodName,
        indexMethodName: "arrayToObjectKey",
        indexTypeName,
        indexColumns,
        apiPath,
        apiPathParams,
        apiPathByKey,
        apiPathParamsByKey,
        generateMutation,
        mutationMergeOldData,
        fetcherName,
        fetcherNameByKey,
      }

      console.log(result)
      return result
    },

    actions: [
      {
        type: "add",
        path: "../db/postgresMainDatabase/schemas/{{schema}}/{{tableCamelName}}.ts",
        templateFile: "plop-templates/getTable/dbGetTable.hbs",
        force: true,
      },
      { type: "add", path: "../{{apiPath}}", templateFile: "plop-templates/getTable/apiGetTable.hbs", force: true },
      {
        type: "add",
        path: "../{{apiPathByKey}}",
        templateFile: "plop-templates/getTable/apiGetTableByKey.hbs",
        force: true,
      },
      {
        type: "add",
        path: "../methods/hooks/{{schema}}/core/useFetch{{schemaTablePascalName}}.ts",
        templateFile: "plop-templates/getTable/hookGetTable.hbs",
        force: true,
      },
      {
        type: "add",
        path: "../methods/hooks/{{schema}}/core/useFetch{{schemaTablePascalName}}ByKey.ts",
        templateFile: "plop-templates/getTable/hookGetTableByKey.hbs",
        force: true,
      },
      {
        type: "add",
        path: "../methods/server-fetchers/{{schema}}/core/get{{schemaTablePascalName}}Server.ts",
        templateFile: "plop-templates/getTable/hookGetTableServer.hbs",
        force: true,
      },
      {
        type: "add",
        path: "../methods/server-fetchers/{{schema}}/core/get{{schemaTablePascalName}}ByKeyServer.ts",
        templateFile: "plop-templates/getTable/hookGetTableByKeyServer.hbs",
        force: true,
      },
      {
        type: "add",
        path: "../methods/services/{{schema}}/{{fetcherName}}Service.ts",
        templateFile: "plop-templates/getTable/serviceGetTable.hbs",
        force: true,
      },
      {
        type: "add",
        path: "../methods/services/{{schema}}/{{fetcherNameByKey}}Service.ts",
        templateFile: "plop-templates/getTable/serviceGetTableByKey.hbs",
        force: true,
      },
      {
        type: "modify",
        path: "../store/atoms.ts",
        pattern: /((?:^"use client"\n)?(?:import[\s\S]*?\n))(?!import)/m,
        template: `$&import { {{indexTypeName}} } from "@/db/postgresMainDatabase/schemas/{{schema}}/{{tableCamelName}}"\n`,
      },
      {
        type: "modify",
        path: "../store/atoms.ts",
        pattern: /(\/\/Tables\s*\n)/,
        template: `$1export const {{tableCamelName}}Atom = atom<{{indexTypeName}}>({})\n`,
      },
      {
        type: "modify",
        path: "../.vscode/snippets.code-snippets",
        pattern: /(?=\/\/Automatic Snippets\s*\n)/,
        templateFile: "plop-templates/getTable/snippetHookTable.hbs",
      },
      {
        type: "modify",
        path: "../.vscode/snippets.code-snippets",
        pattern: /(?=\/\/Automatic Snippets\s*\n)/,
        templateFile: "plop-templates/getTable/snippetHookTableByKey.hbs",
      },
      {
        type: "add",
        path: "../methods/hooks/{{schema}}/core/useMutate{{schemaTablePascalName}}.ts",
        templateFile: "plop-templates/getTable/hookMutateTable.hbs",
        force: true,
        skip: (a) => (a.generateMutation ? false : "Pomijam generowanie useMutate..."),
      },
      {
        type: "add",
        path: "../methods/hooks/{{schema}}/core/useMutate{{schemaTablePascalName}}ByKey.ts",
        templateFile: "plop-templates/getTable/hookMutateTableByKey.hbs",
        force: true,
        skip: (a) => (a.generateMutation ? false : "Pomijam generowanie useMutate..."),
      },
      {
        type: "add",
        path: "./answerHistory/getTable/{{schema}}_{{table}}_answers.json",
        templateFile: "plop-templates/answerHistory.hbs",
        force: true,
      },
      {
        type: "add",
        path: "../methods/hooks/{{schema}}/core/useFetch{{schemaTablePascalName}}.md",
        templateFile: "plop-templates/getTable/skillCreatorTable.hbs",
        force: true,
      },
      {
        type: "add",
        path: "../methods/hooks/{{schema}}/core/useFetch{{schemaTablePascalName}}ByKey.md",
        templateFile: "plop-templates/getTable/skillCreatorTableByKey.hbs",
        force: true,
      },
      { type: "PrettierFormat" },
    ],
  })
}
