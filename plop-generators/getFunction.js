import { getArgsArray, parseArgsToList, parseParamsFields, snakeToCamel, snakeToPascal } from "./helpers.js"
import { fetchMethodArgs, fetchMethodResultColumns, fetchMethods, fetchSchemas } from "./queries.js"

// Generator plop
export default function getMethod(plop) {
  plop.setGenerator("Get Function", {
    description: "Generate TypeScript types and fetcher from Postgres method",

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

      const methods = await fetchMethods(schema)

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

      const name = method
      const camelName = methodCamelName
      const pascalName = methodPascalName

      // Zapewniamy że używamy parseParamsFields z helpers
      const argsStr = await fetchMethodArgs(schema, method)
      const resultColumns = await fetchMethodResultColumns(schema, method)
      const paramsFields = parseParamsFields(argsStr) // DRY, helpers version
      const tsArgsList = parseArgsToList(argsStr)
      const argsArray = getArgsArray(argsStr)
      const argsArrayString = argsArray.join(", ")
      const sqlParamsPlaceholders = argsArray.map((_, i) => `$${i + 1}`).join(", ")
      const methodPascalName = snakeToPascal(method)
      const methodCamelName = snakeToCamel(method)

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

      const typeRecordName = indexFields.map((f) => f.pascalName).join("")
      const indexMethodName = indexFields.length > 1 ? "arrayToObjectKeysId" : "arrayToObjectKeyId"
      const indexMethodArgs = indexFields.map((f) => `"${f.camelName}"`).join(", ")

      const tsReturnType = `export type T${methodPascalName} = {\n${resultColumns.map((c) => `  ${c.camelName}: ${c.type}`).join("\n")}\n}`

      console.log({
        schema,
        method,
        methodPascalName,
        methodCamelName,
        tsArgsList,
        paramsFields,
        argsArrayString,
        sqlParamsPlaceholders,
        tsReturnType,
        indexFields,
        typeRecordName,
        indexMethodName,
        indexMethodArgs,
      })

      return {
        schema,
        method: name,
        methodCamelName: camelName,
        methodPascalName: pascalName,
        name,
        camelName,
        pascalName,
        tsArgsList,
        paramsFields,
        argsArrayString,
        sqlParamsPlaceholders,
        tsReturnType,
        indexFields,
        typeRecordName,
        indexMethodName,
        indexMethodArgs,
      }
    },

    actions: [
      {
        type: "add",
        path: "db/postgresMainDatabase/schemas/{{schema}}/{{methodCamelName}}.tsx",
        templateFile: "plop-templates/dbGetFunction.hbs",
        force: true,
      },
      {
        type: "add",
        path: "app/api/{{methodCamelName}}/route.tsx",
        templateFile: "plop-templates/apiGetFunction.hbs",
        force: true,
      },
      {
        type: "add",
        path: "methods/hooks/{{schema}}/core/useFetch{{methodPascalName}}.tsx",
        templateFile: "plop-templates/hookGetFunction.hbs",
        force: true,
      },
      {
        type: "add",
        path: "methods/fetchers/{{schema}}/fetch{{methodPascalName}}Server.ts",
        templateFile: "plop-templates/fetchServerGetFunction.hbs",
        force: true,
      },
      {
        type: "modify",
        path: "store/atoms.ts",
        pattern: /((?:^"use client"\n)?(?:import[\s\S]*?\n))(?!import)/m,
        template: `$&import { T{{methodPascalName}}RecordBy{{typeRecordName}} } from "@/db/postgresMainDatabase/schemas/{{schema}}/{{methodCamelName}}"\n`,
      },
      {
        type: "modify",
        path: "store/atoms.ts",
        pattern: /(\/\/Functions\s*\n)/,
        template: `$1export const {{methodCamelName}}Atom = atom<T{{methodPascalName}}RecordBy{{typeRecordName}}>({})\n`,
      },
    ],
  })
}
