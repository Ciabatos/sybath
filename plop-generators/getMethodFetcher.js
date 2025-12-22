import {
  getArgsArray,
  parseParamsFields,
  snakeToCamel,
  snakeToKebab,
  snakeToPascal,
  stripPrefix,
} from "./helpers/helpers.js"
import { fetchFunction, fetchMethodArgs, fetchMethodResultColumns, fetchSchemas } from "./helpers/queries.js"
// Generator plop
export default function getMethodFetcher(plop) {
  plop.setGenerator("Get Data From Function", {
    description: "Generate fetcher from Postgres method",

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

      const methods = await fetchFunction(schema)

      if (methods.length === 0) {
        throw new Error(`Brak metod w schemacie: ${schema}`)
      }

      const { method } = await inquirer.prompt([
        {
          type: "list",
          name: "method",
          message: "Wybierz metodę:",
          choices: methods,
        },
      ])

      // Ustal nazwy po wyborze metody
      const methodWithoutPrefix = stripPrefix(method)
      const methodCamelName = snakeToCamel(methodWithoutPrefix)
      const methodPascalName = snakeToPascal(methodWithoutPrefix)
      const methodTypeName = `T${methodPascalName}`
      const methodParamsTypeName = `${methodTypeName}Params`

      // Zapewniamy że używamy parseParamsFields z helpers
      const argsStr = await fetchMethodArgs(schema, method)
      const resultColumns = await fetchMethodResultColumns(schema, method)

      // Ujednolicone pole methodColumns (tak jak w getTable)
      const methodColumns = resultColumns.map((col) => ({
        name: col.name || col.camelName,
        camelName: col.camelName,
        pascalName: snakeToPascal(col.name || col.camelName),
        tsType: col.type,
        optional: "",
      }))

      // nazwa wrappera (funkcja generowanego get...)
      const methodName = snakeToCamel(method)

      const methodParamsColumns = parseParamsFields(argsStr) // DRY, helpers version
      const argsArray = getArgsArray(argsStr)
      const sqlParamsPlaceholders = argsArray.map((_, i) => `$${i + 1}`).join(", ")

      // Zapytaj użytkownika o wybór kolumn dla indexu
      const { selectedColumnsIndex } = await inquirer.prompt([
        {
          type: "checkbox",
          name: "selectedColumnsIndex",
          message: "Wybierz kolumny dla indexu do szybkiego wyszukiwania krotki po stronie Aplikacji:",
          choices: resultColumns.map((f) => ({
            name: `${f.camelName} (${f.type})`,
            value: f.camelName,
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

      // Filtruj tylko wybrane kolumny dla indexu
      const indexFields = resultColumns.filter((f) => selectedColumnsIndex.includes(f.camelName))

      // Formatuj nazwy dla indexu
      indexFields.forEach((f) => {
        f.pascalName = snakeToPascal(f.camelName)
      })

      // indexColumns: kolumny wybrane dla indeksu (struktura jak w getTable)
      const indexColumns = methodColumns.filter((c) => selectedColumnsIndex.includes(c.camelName))

      // nazwa fragmentu typu dla indeksu
      const indexTypeMethodName = indexColumns.map((f) => f.pascalName).join("")
      const indexMethodParams = `[${indexColumns.map((f) => `"${snakeToCamel(f.name)}"`).join(", ")}]`
      const indexParamsColumns = methodParamsColumns.map((f) => snakeToCamel(f.name)).join(", ")
      const indexTypeName = methodTypeName + "RecordBy" + indexTypeMethodName
      const indexMethodName = "arrayToObjectKey"

      const apiParamPathSquareBrackets = methodParamsColumns.length
        ? "/" + methodParamsColumns.map((f) => `[${f.camelName}]`).join("/")
        : ""
      const apiParamPath = methodParamsColumns.length
        ? "/" + methodParamsColumns.map((f) => `\${params.${f.camelName}}`).join("/")
        : ""

      //rpc jednoznacznie oznacza “remote procedure call”
      const methodKebabName = snakeToKebab(method)
      const apiPath = `app/api/${schema}/rpc/${methodKebabName}${apiParamPathSquareBrackets}/route.ts`
      const apiPathParams = `api/${schema}/rpc/${methodKebabName}${apiParamPath}`

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
          message:
            "Czy zmergować stare dane z atomu do nowych danych przy użyciu Mutate ? (pytanie: czy nowy rekord, ZAWSZE posiada wszystkie stare rekordy ?) ",
          choices: [
            { name: "Nie", value: false },
            { name: "Tak", value: true },
          ],
          when: () => generateMutation === true,
        },
      ])

      console.log({
        schema,
        method,
        methodCamelName,
        methodPascalName,
        methodKebabName,
        methodName,
        methodTypeName,
        methodParamsTypeName,
        methodParamsColumns,
        methodColumns,
        indexMethodParams,
        indexParamsColumns,
        indexTypeMethodName,
        indexMethodName,
        indexTypeName,
        indexColumns,
        sqlParamsPlaceholders,
        apiPath,
        apiPathParams,
        generateMutation,
        mutationMergeOldData,
      })

      return {
        schema,
        method,
        methodCamelName,
        methodPascalName,
        methodKebabName,
        methodName,
        methodTypeName,
        methodParamsTypeName,
        methodParamsColumns,
        methodColumns,
        indexMethodParams,
        indexParamsColumns,
        indexTypeMethodName,
        indexMethodName,
        indexTypeName,
        indexColumns,
        sqlParamsPlaceholders,
        apiPath,
        apiPathParams,
        generateMutation,
        mutationMergeOldData,
      }
    },

    actions: [
      {
        type: "add",
        path: "../db/postgresMainDatabase/schemas/{{schema}}/{{methodCamelName}}.ts",
        templateFile: "plop-templates/methodFetcher/dbGetMethodFetcher.hbs",
        force: true,
      },
      {
        type: "add",
        path: "../{{apiPath}}",
        templateFile: "plop-templates/methodFetcher/apiGetMethodFetcher.hbs",
        force: true,
      },
      {
        type: "add",
        path: "../methods/hooks/{{schema}}/core/useFetch{{methodPascalName}}.ts",
        templateFile: "plop-templates/methodFetcher/hookGetMethodFetcher.hbs",
        force: true,
      },
      {
        type: "add",
        path: "../methods/server-fetchers/{{schema}}/core/{{methodName}}Server.ts",
        templateFile: "plop-templates/methodFetcher/hookGetMethodFetcherServer.hbs",
        force: true,
      },
      {
        type: "add",
        path: "../methods/services/{{schema}}/fetch{{methodPascalName}}.ts",
        templateFile: "plop-templates/methodFetcher/serviceGetMethodFetcher.hbs",
        force: true,
      },
      {
        type: "modify",
        path: "../store/atoms.ts",
        pattern: /((?:^"use client"\n)?(?:import[\s\S]*?\n))(?!import)/m,
        template: `$&import { {{indexTypeName}} } from "@/db/postgresMainDatabase/schemas/{{schema}}/{{methodCamelName}}"\n`,
      },
      {
        type: "modify",
        path: "../store/atoms.ts",
        pattern: /(\/\/Functions\s*\n)/,
        template: `$1export const {{methodCamelName}}Atom = atom<{{indexTypeName}}>({})\n`,
      },
      {
        type: "modify",
        path: "../.vscode/snippets.code-snippets",
        pattern: /(?=\/\/Automatic Snippets\s*\n)/,
        templateFile: "plop-templates/methodFetcher/snippetHookMethod.hbs",
      },
      {
        type: "add",
        path: "../methods/hooks/{{schema}}/core/useMutate{{methodPascalName}}.ts",
        templateFile: "plop-templates/methodFetcher/hookMutateMethodFetcher.hbs",
        force: true,
        skip(answers) {
          return answers.generateMutation ? false : "Pomijam generowanie useMutate..."
        },
      },
      // {
      //   type: "PrettierFormat",
      // },
    ],
  })
}
