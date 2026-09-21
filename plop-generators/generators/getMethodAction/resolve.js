import { snakeToCamel, snakeToPascal } from "../../helpers/helpers.js"
import { fetchCompositeType, fetchMethodArgs, fetchMethodResultColumns } from "../../helpers/queries.js"

export async function resolveGetMethodAction({ schema, method }) {
  const entityCamelName = snakeToCamel(method)
  const entityPascalName = snakeToPascal(method)

  const methodTypeName = `T${entityPascalName}`
  const methodParamsTypeName = `${methodTypeName}Params`

  const { methodParamsColumns, argsArray, argsCompositeTypes } = await fetchMethodArgs(schema, method)
  const { resultColumns } = await fetchMethodResultColumns(schema, method)

  const jsonbColumns = resultColumns.filter((col) => col.type === "jsonb")
  if (jsonbColumns.length > 0) {
    const cols = jsonbColumns.map((c) => c.column_name).join(", ")
    throw new Error(`❌ Aborting generator: jsonb columns detected (${cols}). Please add data type for jsonb manually.`)
  }

  const methodColumns = resultColumns.map((col) => ({
    name: col.name || col.camelName,
    camelName: col.camelName,
    pascalName: snakeToPascal(col.name || col.camelName),
    tsType: col.type,
    optional: "",
  }))

  const compositeDefinitions = []
  for (const typeName of argsCompositeTypes) {
    const fields = await fetchCompositeType(schema, method)
    const pascal = snakeToPascal(typeName)
    compositeDefinitions.push({ typeName: `T${pascal}`, fields })
  }

  const actionName = `${entityCamelName}Action`
  const dbFunctionName = entityCamelName
  const sqlFunctionName = method
  const sqlParamsPlaceholders = argsArray.map((_, i) => `$${i + 1}`).join(", ")

  const promptAnswers = { schema, method, usePrevious: false }

  const filesCreated = [
    `methods/actions/${schema}/${actionName}.ts`,
    `methods/actions/${schema}/${actionName}.md`,
    `db/postgresMainDatabase/schemas/${schema}/${entityCamelName}.ts`,
    `methods/services/${schema}/${entityCamelName}Service.ts`,
  ]

  const dateCreated = new Date().toISOString()

  return {
    promptAnswers,
    schema,
    method,
    entityCamelName,
    entityPascalName,
    actionName,
    dbFunctionName,
    methodTypeName,
    methodParamsTypeName,
    methodParamsColumns,
    methodColumns,
    sqlFunctionName,
    sqlParamsPlaceholders,
    compositeDefinitions,
    dateCreated,
    filesCreated,
    generatorName: "getMethodAction",
  }
}
