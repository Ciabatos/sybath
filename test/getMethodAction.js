import fs from "fs"
import path from "path"
import { snakeToCamel, snakeToPascal } from "./helpers/helpers.js"
import {
  fetchCompositeType,
  fetchFucntionForAction,
  fetchMethodArgs,
  fetchMethodResultColumns,
  fetchSchemas,
} from "./helpers/queries.js"

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

export default function getMethodAction(plop) {
  plop.setGenerator("getMethodAction", {
    description: "Generate action from Postgres method",

    prompts: async (inquirer) => {
      // 1. Schema
      const schemas = await fetchSchemas()
      if (!schemas.length) throw new Error("Brak dostępnych schematów")
      const { schema } = await inquirer.prompt([
        { type: "list", name: "schema", message: "Wybierz schemat:", choices: schemas },
      ])

      // 2. Method
      const methods = await fetchFucntionForAction(schema)
      if (!methods.length) throw new Error(`Brak metod w schemacie: ${schema}`)
      const { method } = await inquirer.prompt([
        { type: "list", name: "method", message: "Wybierz metodę:", choices: methods },
      ])

      // 3. History
      const historyFile = historyPath("getMethodAction", schema, method)
      const prev = await loadPreviousAnswers(inquirer, historyFile, `${schema}.${method}`)
      if (prev) return prev

      // 4. Derive names
      const methodCamelName = snakeToCamel(method)
      const methodPascalName = snakeToPascal(method)
      const methodTypeName = `T${methodPascalName}`

      // 5. DB introspection
      const { methodParamsColumns, argsArray, argsCompositeTypes } = await fetchMethodArgs(schema, method)
      const { resultColumns } = await fetchMethodResultColumns(schema, method)

      const methodColumns = resultColumns.map((col) => ({
        name: col.name ?? col.camelName,
        camelName: col.camelName,
        pascalName: snakeToPascal(col.name ?? col.camelName),
        tsType: col.type,
        optional: "",
      }))

      const compositeDefinitions = await Promise.all(
        argsCompositeTypes.map(async (typeName) => ({
          typeName: `T${snakeToPascal(typeName)}`,
          fields: await fetchCompositeType(schema, method),
        })),
      )

      const result = {
        promptAnswers: { schema, method, usePrevious: false },
        schema,
        method,
        methodCamelName,
        methodPascalName,
        methodName: `${methodCamelName}Action`,
        methodTypeName,
        methodParamsTypeName: `${methodTypeName}Params`,
        methodParamsColumns,
        methodColumns,
        sqlParamsPlaceholders: argsArray.map((_, i) => `$${i + 1}`).join(", "),
        compositeDefinitions,
      }

      console.log(result)
      return result
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
        path: "../methods/actions/{{schema}}/{{methodName}}.md",
        templateFile: "plop-templates/methodAction/skillCreatorAction.hbs",
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
        path: "../methods/services/{{schema}}/{{methodCamelName}}Service.ts",
        templateFile: "plop-templates/methodAction/serviceGetMethodAction.hbs",
        force: true,
      },
      {
        type: "add",
        path: "./answerHistory/getMethodAction/{{schema}}_{{method}}_answers.json",
        templateFile: "plop-templates/answerHistory.hbs",
        force: true,
      },
      { type: "PrettierFormat" },
    ],
  })
}
