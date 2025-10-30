import { fetchSchemas, fetchTables, fetchColumns } from "../shared/queries"
import { snakeToCamel, snakeToPascal } from "../shared/naming"
import {
  createIndexPrompt,
  createParamsPrompt,
  createIndexConfig,
} from "../shared/prompt-helpers"

export const getTablePrompts = async (inquirer: any) => {
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

  // 2. Wybór tabeli
  const tables = await fetchTables(schema)
  if (tables.length === 0) {
    throw new Error(`Brak tabel w schemacie: ${schema}`)
  }

  const { table } = await inquirer.prompt([
    {
      type: "list",
      name: "table",
      message: "Wybierz tabelę:",
      choices: tables,
    },
  ])

  // 3. Pobranie kolumn
  const fields = await fetchColumns(schema, table)
  if (fields.length === 0) {
    throw new Error(`Brak kolumn w tabeli ${schema}.${table}`)
  }

  // 4. Wybór kolumn dla indexu
  const { selectedColumnsIndex } = await inquirer.prompt([
    createIndexPrompt(fields),
  ])

  const indexFields = fields.filter((f) => selectedColumnsIndex.includes(f.name))
  const indexConfig = createIndexConfig(indexFields)

  // 5. Wybór parametrów
  const { paramsColumns } = await inquirer.prompt([createParamsPrompt(fields)])

  const paramsFields = fields.filter((f) => paramsColumns.includes(f.name))
  const paramsList = paramsFields.map((f) => f.camelName).join(", ")

  // 6. Generowanie nazw
  const tablePascalName = snakeToPascal(table)
  const tableCamelName = snakeToCamel(table)
  const typeName = `T${snakeToPascal(schema)}${tablePascalName}`
  const methodName = `${snakeToPascal(schema)}${tablePascalName}`

  console.log({
    schema,
    table,
    tablePascalName,
    tableCamelName,
    typeName,
    methodName,
    typeRecordName: indexConfig.typeRecordName,
    fields,
    indexFields,
    indexMethodName: indexConfig.methodName,
    indexMethodArgs: indexConfig.methodArgs,
    paramsFields,
    paramsList,
  })

  return {
    schema,
    table,
    tablePascalName,
    tableCamelName,
    typeName,
    methodName,
    typeRecordName: indexConfig.typeRecordName,
    fields,
    indexFields,
    indexMethodName: indexConfig.methodName,
    indexMethodArgs: indexConfig.methodArgs,
    paramsFields,
    paramsList,
  }
}
