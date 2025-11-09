import { getArgsArray, parseParamsFields, snakeToCamel, snakeToPascal } from "./helpers/helpers.js"
import { fetchFunction, fetchMethodArgs, fetchMethodResultColumns, fetchSchemas } from "./helpers/queries.js"

// Generator plop
export default function getMethodFetcher(plop) {
  plop.setGenerator("Get Data From Function", {
    description: "Generate fetcher from Postgres scalar method",

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

      // Ustal nazwy po wyborze metody
      const methodCamelName = snakeToCamel(method)
      const methodPascalName = snakeToPascal(method)
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
      const methodName = `get${methodPascalName}`

      const methodParamsColumns = parseParamsFields(argsStr) // DRY, helpers version
      const argsArray = getArgsArray(argsStr)
      const sqlParamsPlaceholders = argsArray.map((_, i) => `$${i + 1}`).join(", ")

      // Zapytaj użytkownika o wybór kolumn dla indexu
      const { selectedColumnsIndex } = await inquirer.prompt([
        {
          type: "checkbox",
          name: "selectedColumnsIndex",
          message: "Wybierz kolumny dla indexu:",
          choices: resultColumns.map((f) => ({
            name: `${f.camelName} (${f.type})`,
            value: f.camelName,
            checked: false,
          })),
          validate: (answer) => {
            if (answer.length < 1) {
              return "Musisz zaznaczyć przynajmniej jedną kolumnę."
            }
            if (answer.length > 2) {
              return "Możesz zaznaczyć maksymalnie dwie kolumny."
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
      const indexMethodParams = indexColumns.map((f) => `"${snakeToCamel(f.name)}"`).join(", ")
      const indexParamsColumns = methodParamsColumns.map((f) => snakeToCamel(f.name)).join(", ")
      const indexTypeName = methodTypeName + "RecordBy" + indexTypeMethodName
      const indexMethodName = indexFields.length > 1 ? "arrayToObjectKeysId" : "arrayToObjectKeyId"

      const apiParamPathSquareBrackets = methodParamsColumns.length ? "/" + methodParamsColumns.map((f) => `[${f.camelName}]`).join("/") : ""
      const apiParamPath = methodParamsColumns.length ? "/" + methodParamsColumns.map((f) => `\${params.${f.camelName}}`).join("/") : ""

      const apiPath = `app/api/${methodCamelName}${apiParamPathSquareBrackets}/route.tsx`
      const apiPathParams = `/api/${methodCamelName}${apiParamPath}`

      console.log({
        schema,
        method,
        methodCamelName,
        methodPascalName,
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
      })

      return {
        schema,
        method,
        methodCamelName,
        methodPascalName,
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
      }
    },

    actions: [
      {
        type: "add",
        path: "db/postgresMainDatabase/schemas/{{schema}}/{{methodCamelName}}.tsx",
        templateFile: "plop-templates/dbGetMethodFetcher.hbs",
        force: true,
      },
      {
        type: "add",
        path: "{{apiPath}}",
        templateFile: "plop-templates/apiGetMethodFetcher.hbs",
        force: true,
      },
      {
        type: "add",
        path: "methods/hooks/{{schema}}/core/useFetch{{methodPascalName}}.tsx",
        templateFile: "plop-templates/hookGetMethodFetcher.hbs",
        force: true,
      },
      {
        type: "add",
        path: "methods/fetchers/{{schema}}/fetch{{methodPascalName}}Server.ts",
        templateFile: "plop-templates/hookGetMethodFetcherServer.hbs",
        force: true,
      },
      {
        type: "modify",
        path: "store/atoms.ts",
        pattern: /((?:^"use client"\n)?(?:import[\s\S]*?\n))(?!import)/m,
        template: `$&import { {{indexTypeName}} } from "@/db/postgresMainDatabase/schemas/{{schema}}/{{methodCamelName}}"\n`,
      },
      {
        type: "modify",
        path: "store/atoms.ts",
        pattern: /(\/\/Functions\s*\n)/,
        template: `$1export const {{methodCamelName}}Atom = atom<{{indexTypeName}}>({})\n`,
      },
    ],
  })
}
