import { getArgsArray, parseParamsFields, snakeToCamel, snakeToPascal } from "./helpers/helpers.js"
import { fetchFucntionScalar, fetchMethodArgs, fetchMethodResultColumns, fetchSchemas } from "./helpers/queries.js"

// Generator plop
export default function getMethodAction(plop) {
  plop.setGenerator("Get Action", {
    description: "Generate action from Postgres non-scalar method",

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

      const methods = await fetchFucntionScalar(schema)

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
        path: "methods/actions/{{schema}}/{{methodName}}.ts",
        templateFile: "plop-templates/actionMethodAction.hbs",
        force: true,
      },
      {
        type: "add",
        path: "db/postgresMainDatabase/schemas/{{schema}}/{{methodCamelName}}.tsx",
        templateFile: "plop-templates/dbGetMethodAction.hbs",
        force: true,
      },
    ],
  })
}
