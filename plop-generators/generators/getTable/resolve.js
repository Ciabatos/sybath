import { camelToKebab, mapSQLTypeToTS, snakeToCamel, snakeToPascal } from "../../helpers/helpers.js"
import {
  createMethodGetRecords,
  createMethodGetRecordsByKey,
  fetchColumns,
  fetchMethodArgs,
} from "../../helpers/queries.js"

export async function resolveGetTable({
  schema,
  table,
  selectedColumnsIndex,
  paramsColumns,
  generateMutation,
  mutationMergeOldData,
}) {
  const rows = await fetchColumns(schema, table)

  const jsonbColumns = rows.filter((col) => mapSQLTypeToTS(col.data_type) === "jsonb")
  if (jsonbColumns.length > 0) {
    const cols = jsonbColumns.map((c) => c.column_name).join(", ")
    throw new Error(`❌ Aborting generator: jsonb columns detected (${cols}). Please add data type for jsonb manually.`)
  }

  const methodColumns = rows.map((col) => ({
    name: col.column_name,
    camelName: snakeToCamel(col.column_name),
    tsType: mapSQLTypeToTS(col.data_type),
    optional: col.is_nullable === "YES" ? "?" : "",
  }))

  const indexColumns = methodColumns.filter((f) => selectedColumnsIndex.includes(f.name))
  indexColumns.forEach((f) => {
    f.pascalName = snakeToPascal(f.name)
  })

  const methodParamsColumns = methodColumns
    .filter((f) => paramsColumns.includes(f.name))
    .map((f) => ({
      name: f.name,
      camelName: f.camelName,
      tsType: f.tsType,
    }))

  // --- nazwy bytu ---
  const entityPascalName = snakeToPascal(table)
  const entityCamelName = snakeToCamel(table)
  const entityKebabName = camelToKebab(entityCamelName)
  const schemaEntityPascalName = snakeToPascal(schema) + entityPascalName

  const methodTypeName = "T" + schemaEntityPascalName
  const methodParamsTypeName = methodTypeName + "Params"

  // --- funkcje TS w pliku schema ---
  const dbFunctionName = "get" + schemaEntityPascalName
  const dbFunctionByKeyName = dbFunctionName + "ByKey"

  // --- funkcje Postgresa ---
  const sqlFunctionName = `get_${table}`
  const sqlFunctionByKeyName = `get_${table}_by_key`

  // --- serwisy ---
  const fetcherName = "fetch" + schemaEntityPascalName
  const fetcherByKeyName = fetcherName + "ByKey"

  // --- indeks ---
  const indexTypeMethodName = indexColumns.map((f) => f.pascalName).join("")
  const indexMethodName = "arrayToObjectKey"
  const indexTypeName = methodTypeName + "RecordBy" + indexTypeMethodName
  const indexMethodParams = `[${indexColumns.map((f) => `"${snakeToCamel(f.name)}"`).join(", ")}]`
  const indexParamsColumns = methodParamsColumns.map((f) => snakeToCamel(f.name)).join(", ")

  // --- SQL side-effect ---
  const createdByKey = await createMethodGetRecordsByKey(schema, table, indexParamsColumns)
  const created = await createMethodGetRecords(schema, table)
  const sqlMethodCreated = [createdByKey, created]

  const { argsArray } = await fetchMethodArgs(schema, sqlFunctionByKeyName)
  const sqlParamsPlaceholders = argsArray.map((_, i) => `$${i + 1}`).join(", ")

  // --- API ---
  const apiParamPathSquareBrackets = methodParamsColumns.length
    ? "/" + methodParamsColumns.map((f) => `[${f.camelName}]`).join("/")
    : ""
  const apiParamPath = methodParamsColumns.length
    ? "/" + methodParamsColumns.map((f) => `\${params.${f.camelName}}`).join("/")
    : ""

  const apiPath = `app/api/${schema}/${entityKebabName}/route.ts`
  const apiPathByKey = `app/api/${schema}/${entityKebabName}${apiParamPathSquareBrackets}/route.ts`
  const apiPathParams = `/api/${schema}/${entityKebabName}`
  const apiPathParamsByKey = `/api/${schema}/${entityKebabName}${apiParamPath}`

  const promptAnswers = {
    schema,
    table,
    usePrevious: false,
    selectedColumnsIndex,
    paramsColumns,
    generateMutation,
    mutationMergeOldData,
  }

  const filesCreated = [
    `db/postgresMainDatabase/schemas/${schema}/${entityCamelName}.ts`,
    `${apiPath}`,
    `${apiPathByKey}`,
    `methods/hooks/${schema}/core/useFetch${schemaEntityPascalName}.ts`,
    `methods/hooks/${schema}/core/useFetch${schemaEntityPascalName}ByKey.ts`,
    `methods/server-fetchers/${schema}/core/get${schemaEntityPascalName}ByKeyServer.ts`,
    `methods/services/${schema}/${fetcherName}Service.ts`,
    `methods/services/${schema}/${fetcherByKeyName}Service.ts`,
    `store/atoms/getTable/${entityCamelName}Atom.ts`,
    `.vscode/use${schemaEntityPascalName}.code-snippets`,
    `.vscode/use${schemaEntityPascalName}ByKey.code-snippets`,
    `methods/hooks/${schema}/core/useMutate${schemaEntityPascalName}.ts`,
    `methods/hooks/${schema}/core/useMutate${schemaEntityPascalName}ByKey.ts`,
    `methods/hooks/${schema}/core/useFetch${schemaEntityPascalName}.md`,
    `methods/hooks/${schema}/core/useFetch${schemaEntityPascalName}ByKey.md`,
  ]

  const dateCreated = new Date().toISOString()

  return {
    promptAnswers,
    schema,
    entityCamelName,
    entityPascalName,
    entityKebabName,
    schemaEntityPascalName,
    methodTypeName,
    methodParamsTypeName,
    methodParamsColumns,
    dbFunctionName,
    dbFunctionByKeyName,
    sqlFunctionName,
    sqlFunctionByKeyName,
    sqlParamsPlaceholders,
    methodColumns,
    indexMethodParams,
    indexParamsColumns,
    indexTypeMethodName,
    indexMethodName,
    indexTypeName,
    indexColumns,
    apiPath,
    apiPathParams,
    apiPathByKey,
    apiPathParamsByKey,
    generateMutation,
    mutationMergeOldData,
    fetcherName,
    fetcherByKeyName,
    dateCreated,
    filesCreated,
    sqlMethodCreated,
    generatorName: "getTable",
  }
}
