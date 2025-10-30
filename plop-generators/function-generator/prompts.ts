import {
  fetchSchemas,
  fetchFunctions,
  fetchFunctionArgs,
  fetchFunctionReturnType,
} from "../shared/queries"
import { snakeToCamel, snakeToPascal } from "../shared/naming"
import { mapSQLTypeToTS } from "../shared/type-mapping"
import {
  createIndexPrompt,
  createIndexConfig,
  parseFunctionArgs,
  parseFunctionReturnColumns,
} from "../shared/prompt-helpers"

export const getFunctionPrompts = async (inquirer: any) => {
  // 1. Wybór schematu
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

  // 2. Wybór funkcji
  const methods = await fetchFunctions(schema)
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

  // 3. Pobranie argumentów funkcji
  const argsStr = await fetchFunctionArgs(schema, method)
  const paramsFields = parseFunctionArgs(argsStr).map((f) => ({
    ...f,
    tsType: mapSQLTypeToTS(f.tsType),
  }))

  // 4. Pobranie typu zwracanego
  const returnType = await fetchFunctionReturnType(schema, method)
  const resultColumns = parseFunctionReturnColumns(returnType).map((f) => ({
    ...f,
    type: mapSQLTypeToTS(f.tsType || f.type),
  }))

  // 5. Wybór kolumn dla indexu
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
      validate: (answer: string[]) => {
        if (answer.length < 1) {
          return "Musisz zaznaczyć przynajmniej jedną kolumnę."
        }
        return true
      },
    },
  ])

  const indexFields = resultColumns.filter((f) =>
    selectedColumnsIndex.includes(f.camelName)
  )
  const indexConfig = createIndexConfig(indexFields)

  // 6. Generowanie pomocniczych zmiennych
  const methodPascalName = snakeToPascal(method)
  const methodCamelName = snakeToCamel(method, true) // z usunięciem p_

  const tsArgsList = paramsFields
    .map((f) => `${f.camelName}: ${f.tsType}`)
    .join(", ")

  const argsArray = paramsFields.map((f) => f.name)
  const argsArrayString = argsArray.join(", ")
  const sqlParamsPlaceholders = argsArray.map((_, i) => `$${i + 1}`).join(", ")

  const tsReturnType = `export type T${methodPascalName} = {\n${resultColumns
    .map((c) => `  ${c.camelName}: ${c.type}`)
    .join("\n")}\n}`

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
    typeRecordName: indexConfig.typeRecordName,
    indexMethodName: indexConfig.methodName,
    indexMethodArgs: indexConfig.methodArgs,
  })

  return {
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
    typeRecordName: indexConfig.typeRecordName,
    indexMethodName: indexConfig.methodName,
    indexMethodArgs: indexConfig.methodArgs,
  }
}
