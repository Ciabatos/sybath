import fs from "fs"
import path from "path"
import { snakeToCamel, snakeToKebab, snakeToPascal, stripPrefix } from "./helpers/helpers.js"
import {
  fetchCompositeType, fetchFunction, fetchMethodArgs,
  fetchMethodResultColumns, fetchSchemas,
} from "./helpers/queries.js"

// ─── History helpers ──────────────────────────────────────────────────────────

function historyPath(generatorName, schema, key) {
  const dir = path.resolve(process.cwd(), `plop-generators/answerHistory/${generatorName}`)
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true })
  return path.join(dir, `${schema}_${key}_answers.json`)
}

async function loadPreviousAnswers(inquirer, historyFile, label) {
  if (!fs.existsSync(historyFile)) return null
  const { usePrevious } = await inquirer.prompt([{
    type: "list", name: "usePrevious",
    message: `Znaleziono zapisane ustawienia plop.js dla ${label}. Czy wczytać poprzednie ustawienia?`,
    choices: [{ name: "Tak", value: true }, { name: "Nie", value: false }],
  }])
  const saved = JSON.parse(fs.readFileSync(historyFile, "utf-8"))
  if (usePrevious) { console.log("Wczytano poprzednie ustawienia:", saved); return saved }
  return null
}

// ─── Generator ────────────────────────────────────────────────────────────────

export default function getMethodFetcher(plop) {
  plop.setGenerator("getMethodFetcher", {
    description: "Generate fetcher from Postgres method",

    prompts: async (inquirer) => {
      // 1. Schema
      const schemas = await fetchSchemas()
      if (!schemas.length) throw new Error("Brak dostępnych schematów")
      const { schema } = await inquirer.prompt([{ type: "list", name: "schema", message: "Wybierz schemat:", choices: schemas }])

      // 2. Method
      const methods = await fetchFunction(schema)
      if (!methods.length) throw new Error(`Brak metod w schemacie: ${schema}`)
      const { method } = await inquirer.prompt([{ type: "list", name: "method", message: "Wybierz metodę:", choices: methods }])

      // 3. History
      const historyFile = historyPath("getMethodFetcher", schema, method)
      const prev = await loadPreviousAnswers(inquirer, historyFile, `${schema}.${method}`)
      if (prev) return prev

      // 4. Derive names
      const methodCamelName  = snakeToCamel(stripPrefix(method))
      const methodPascalName = snakeToPascal(stripPrefix(method))
      const methodTypeName   = `T${methodPascalName}`
      const methodKebabName  = snakeToKebab(method)
      const methodName       = snakeToCamel(method)

      // 5. DB introspection
      const { methodParamsColumns, argsArray, argsCompositeTypes } = await fetchMethodArgs(schema, method)
      const { resultColumns, compositeTypes } = await fetchMethodResultColumns(schema, method)

      const methodColumns = resultColumns.map((col) => ({
        name:      col.name ?? col.camelName,
        camelName: col.camelName,
        pascalName: snakeToPascal(col.name ?? col.camelName),
        tsType:    col.type,
        optional:  "",
      }))

      const compositeDefinitions = await Promise.all(
        compositeTypes.map(async (typeName) => ({
          typeName: `T${snakeToPascal(typeName)}`,
          fields:   await fetchCompositeType(schema, method),
        }))
      )

      // 6. Index columns prompt
      const { selectedColumnsIndex } = await inquirer.prompt([{
        type: "checkbox", name: "selectedColumnsIndex",
        message: "Wybierz kolumny dla indexu do szybkiego wyszukiwania krotki po stronie Aplikacji:",
        default: null,
        choices: resultColumns.map((f) => ({ name: `${f.camelName} (${f.type})`, value: f.camelName, checked: false })),
        validate: (a) => a.length >= 1 || "Musisz zaznaczyć przynajmniej jedną kolumnę.",
      }])

      const indexColumns = methodColumns
        .filter((c) => selectedColumnsIndex.includes(c.camelName))
        .map((c) => ({ ...c, pascalName: snakeToPascal(c.camelName) }))

      // 7. Derived index values
      const indexTypeMethodName   = indexColumns.map((f) => f.pascalName).join("")
      const indexMethodParams     = `[${indexColumns.map((f) => `"${snakeToCamel(f.name)}"`).join(", ")}]`
      const indexParamsColumns    = methodParamsColumns.map((f) => snakeToCamel(f.name)).join(", ")
      const indexTypeName         = `${methodTypeName}RecordBy${indexTypeMethodName}`
      const sqlParamsPlaceholders = argsArray.map((_, i) => `$${i + 1}`).join(", ")

      const apiParamPathSquareBrackets = methodParamsColumns.map((f) => `[${f.camelName}]`).join("/")
      const apiParamPath               = methodParamsColumns.map((f) => `\${params.${f.camelName}}`).join("/")
      const apiPathSuffix              = methodParamsColumns.length ? `/${apiParamPathSquareBrackets}` : ""
      const apiPathParamsSuffix        = methodParamsColumns.length ? `/${apiParamPath}` : ""
      const apiPath      = `app/api/${schema}/rpc/${methodKebabName}${apiPathSuffix}/route.ts`
      const apiPathParams = `/api/${schema}/rpc/${methodKebabName}${apiPathParamsSuffix}`

      // 8. Mutation prompts
      const { generateMutation } = await inquirer.prompt([{
        type: "list", name: "generateMutation",
        message: "Czy chcesz wygenerować także hook useMutate ? Służy do szybkiego odświeżania UI po użyciu akcji",
        choices: [{ name: "Nie", value: false }, { name: "Tak", value: true }],
      }])

      const { mutationMergeOldData } = await inquirer.prompt([{
        type: "list", name: "mutationMergeOldData",
        message: "Czy zmergować stare dane z atomu do nowych danych przy użyciu Mutate ?",
        choices: [{ name: "Nie", value: false }, { name: "Tak", value: true }],
        when: () => generateMutation,
      }])

      const result = {
        promptAnswers: { schema, method, usePrevious: false, selectedColumnsIndex, generateMutation, mutationMergeOldData },
        schema, method, methodCamelName, methodPascalName, methodKebabName, methodName,
        methodTypeName, methodParamsTypeName: `${methodTypeName}Params`,
        methodParamsColumns, methodColumns,
        indexMethodParams, indexParamsColumns, indexTypeMethodName,
        indexMethodName: "arrayToObjectKey", indexTypeName, indexColumns,
        sqlParamsPlaceholders, apiPath, apiPathParams,
        generateMutation, mutationMergeOldData, compositeDefinitions,
      }

      console.log(result)
      return result
    },

    actions: [
      { type: "add",    path: "../db/postgresMainDatabase/schemas/{{schema}}/{{methodCamelName}}.ts",          templateFile: "plop-templates/methodFetcher/dbGetMethodFetcher.hbs",           force: true },
      { type: "add",    path: "../{{apiPath}}",                                                                templateFile: "plop-templates/methodFetcher/apiGetMethodFetcher.hbs",           force: true },
      { type: "add",    path: "../methods/hooks/{{schema}}/core/useFetch{{methodPascalName}}.ts",              templateFile: "plop-templates/methodFetcher/hookGetMethodFetcher.hbs",          force: true },
      { type: "add",    path: "../methods/server-fetchers/{{schema}}/core/{{methodName}}Server.ts",            templateFile: "plop-templates/methodFetcher/hookGetMethodFetcherServer.hbs",    force: true },
      { type: "add",    path: "../methods/services/{{schema}}/fetch{{methodPascalName}}Service.ts",            templateFile: "plop-templates/methodFetcher/serviceGetMethodFetcher.hbs",       force: true },
      { type: "modify", path: "../store/atoms.ts",
        pattern:  /((?:^"use client"\n)?(?:import[\s\S]*?\n))(?!import)/m,
        template: `$&import { {{indexTypeName}} } from "@/db/postgresMainDatabase/schemas/{{schema}}/{{methodCamelName}}"\n` },
      { type: "modify", path: "../store/atoms.ts",
        pattern:  /(\/\/Functions\s*\n)/,
        template: `$1export const {{methodCamelName}}Atom = atom<{{indexTypeName}}>({})\n` },
      { type: "modify", path: "../.vscode/snippets.code-snippets",
        pattern:  /(?=\/\/Automatic Snippets\s*\n)/,
        templateFile: "plop-templates/methodFetcher/snippetHookMethod.hbs" },
      { type: "add",    path: "../methods/hooks/{{schema}}/core/useMutate{{methodPascalName}}.ts",             templateFile: "plop-templates/methodFetcher/hookMutateMethodFetcher.hbs",       force: true,
        skip: (a) => a.generateMutation ? false : "Pomijam generowanie useMutate..." },
      { type: "add",    path: "./answerHistory/getMethodFetcher/{{schema}}_{{method}}_answers.json",           templateFile: "plop-templates/answerHistory.hbs",                               force: true },
      { type: "add",    path: "../methods/hooks/{{schema}}/core/useFetch{{methodPascalName}}.md",              templateFile: "plop-templates/methodFetcher/skillCreatorMethod.hbs",            force: true },
      { type: "PrettierFormat" },
    ],
  })
}
