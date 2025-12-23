import fs from "fs"
import path from "path"
import { getArgsArray, parseParamsFields, snakeToCamel, snakeToPascal } from "./helpers/helpers.js"
import { fetchFucntionForAction, fetchMethodArgs, fetchMethodResultColumns, fetchSchemas } from "./helpers/queries.js"

// Generator plop
export default function getMethodAction(plop) {
  plop.setGenerator("getMethodAction", {
    description: "Generate action from Postgres method",

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

      const methods = await fetchFucntionForAction(schema)

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

      const historyDir = path.resolve(process.cwd(), "plop-generators/answerHistory/getMethodAction")
      if (!fs.existsSync(historyDir)) fs.mkdirSync(historyDir, { recursive: true })
      const historyFile = path.join(historyDir, `${schema}_${method}_answers.json`)

      if (fs.existsSync(historyFile)) {
        const { usePrevious } = await inquirer.prompt([
          {
            type: "list",
            name: "usePrevious",
            message: `Znaleziono zapisane ustawienia plop.js dla ${schema}.${method}. Czy wczytać poprzednie ustawienia?`,
            choices: [
              { name: "Tak", value: true },
              { name: "Nie", value: false },
            ],
          },
        ])

        if (usePrevious) {
          const previousAnswers = JSON.parse(fs.readFileSync(historyFile, "utf-8"))
          console.log("Wczytano poprzednie ustawienia:", previousAnswers)
          return previousAnswers
        }
      }

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
      const methodName = `${methodCamelName}Action`

      const methodParamsColumns = parseParamsFields(argsStr) // DRY, helpers version
      const argsArray = getArgsArray(argsStr)
      const sqlParamsPlaceholders = argsArray.map((_, i) => `$${i + 1}`).join(", ")

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
        sqlParamsPlaceholders,
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
        sqlParamsPlaceholders,
      }
    },

    actions: [
      {
        type: "add",
        path: "../methods/actions/{{schema}}/{{methodName}}.ts",
        templateFile: "plop-templates/methodAction/actionGetMethodAction.hbs",
        force: true,
      },
      {
        type: "add",
        path: "../db/postgresMainDatabase/schemas/{{schema}}/{{methodCamelName}}.ts",
        templateFile: "plop-templates/methodAction/dbGetMethodAction.hbs",
        force: true,
      },
      {
        type: "add",
        path: "./answerHistory/getMethodAction/{{schema}}_{{method}}_answers.json",
        templateFile: "plop-templates/answerHistory.hbs",
        force: true,
      },
      // {
      //   type: "PrettierFormat",
      // },
    ],
  })
}
