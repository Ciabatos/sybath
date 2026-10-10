import { snakeToCamel, snakeToKebab, snakeToPascal, stripPrefix } from "../../helpers/helpers.js"
import { fetchCompositeType, fetchMethodArgs, fetchMethodResultColumns } from "../../helpers/queries.js"

export async function resolveGetMethodFetcher({
  schema,
  method,
  selectedColumnsIndex,
  generateMutation,
  mutationMergeOldData,
}) {
  const methodWithoutPrefix = stripPrefix(method)

  const entityCamelName = snakeToCamel(methodWithoutPrefix)
  const entityPascalName = snakeToPascal(methodWithoutPrefix)
  const entityKebabName = snakeToKebab(method)

  const methodTypeName = `T${entityPascalName}`
  const methodParamsTypeName = `${methodTypeName}Params`

  const { methodParamsColumns, argsArray } = await fetchMethodArgs(schema, method)
  const { resultColumns, compositeTypes } = await fetchMethodResultColumns(schema, method)

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
  for (const typeName of compositeTypes) {
    const fields = await fetchCompositeType(schema, method)
    const pascal = snakeToPascal(typeName)
    compositeDefinitions.push({ typeName: `T${pascal}`, fields })
  }

  // --- nazwy ---
  const dbFunctionName = snakeToCamel(method)
  const sqlFunctionName = method
  const sqlParamsPlaceholders = argsArray.map((_, i) => `$${i + 1}`).join(", ")

  const indexColumns = methodColumns.filter((c) => selectedColumnsIndex.includes(c.camelName))

  const indexTypeMethodName = indexColumns.map((f) => f.pascalName).join("")
  const indexMethodName = "arrayToObjectKey"
  const indexTypeName = methodTypeName + "RecordBy" + indexTypeMethodName
  const indexMethodParams = `[${indexColumns.map((f) => `"${snakeToCamel(f.name)}"`).join(", ")}]`
  const indexParamsColumns = methodParamsColumns.map((f) => snakeToCamel(f.name)).join(", ")

  const clientMethodParamsTypeName = `${methodTypeName}ClientParams`
  const clientMethodParamsColumns = methodParamsColumns.filter((f) => f.camelName !== "userId")

  /*
    Hook fetchujący musi być wołany BEZWARUNKOWO (React nie wolno zmieniać liczby
    hooków między renderami), a w composite'ie dane bywają niedostępne —
    np. `clickedMapTile` jest null, dopóki gracz nie kliknie kafelka.

    Dlatego parametry dopuszczają `null`, a klucz SWR to `string | null`.
    SWR pomija request dla klucza `null`, więc hook nic nie odpytuje, dopóki
    parametry nie będą kompletne — bez `if (...) return` wewnątrz hooka.

    `hasAllParamsExpression` trafia prosto do szablonów, więc wyrażenie
    sprawdzające parametry jest zdefiniowane w jednym miejscu.
  */
  const fetchParamsTypeName = `${methodTypeName}FetchParams`
  const hasAllParamsExpression = clientMethodParamsColumns.length
    ? clientMethodParamsColumns.map((f) => `params.${f.camelName} != null`).join(" && ")
    : "true"

  const apiParamPathSquareBrackets = clientMethodParamsColumns.length
    ? "/" + clientMethodParamsColumns.map((f) => `[${f.camelName}]`).join("/")
    : ""
  const apiParamPath = clientMethodParamsColumns.length
    ? "/" + clientMethodParamsColumns.map((f) => `\${params.${f.camelName}}`).join("/")
    : ""

  const apiPath = `app/api/${schema}/rpc/${entityKebabName}${apiParamPathSquareBrackets}/route.ts`
  const apiPathParams = `/api/${schema}/rpc/${entityKebabName}${apiParamPath}`

  /*
    Wspólny budowniczy klucza SWR. Hook fetchujący i hook mutujący MUSZĄ użyć
    tego samego wyrażenia — inaczej klucze się rozjadą i SWR potraktuje to jako
    dwa różne zasoby (cichy brak revalidacji, brak dopasowania optymalnych
    update'ów). Dlatego klucz jest eksportowany z hooka, a mutacja go importuje.
  */
  const swrKeyConstantName = `${snakeToCamel(entityPascalName).toUpperCase()}_SWR_KEY`
  const swrKeyBuilderExpression = clientMethodParamsColumns.length
    ? `(params: ${fetchParamsTypeName}) =>\n  ${hasAllParamsExpression} ? \`${apiPathParams}\` : null`
    : `() => \`${apiPathParams}\``

  // Jawne wiązanie argumentów po nazwie — chroni przed cichym pomieszaniem.
  const sqlParamsExpression = `[${argsArray.map((n) => `params.${snakeToCamel(n)}`).join(", ")}]`

  const promptAnswers = {
    schema,
    method,
    usePrevious: false,
    selectedColumnsIndex,
    generateMutation,
    mutationMergeOldData,
  }

  const filesCreated = [
    `db/postgresMainDatabase/schemas/${schema}/${entityCamelName}.ts`,
    `${apiPath}`,
    `methods/hooks/${schema}/core/useFetch${entityPascalName}.ts`,
    `methods/server-fetchers/${schema}/core/${dbFunctionName}Server.ts`,
    `methods/services/${schema}/fetch${entityPascalName}Service.ts`,
    `store/atoms/getMethodFetcher/${entityCamelName}Atom.ts`,
    `.vscode/use${entityPascalName}.code-snippets`,
    `methods/hooks/${schema}/core/useMutate${entityPascalName}.ts`,
    `methods/hooks/${schema}/core/useFetch${entityPascalName}.md`,
  ]

  const dateCreated = new Date().toISOString()

  return {
    promptAnswers,
    schema,
    method,
    entityCamelName,
    entityPascalName,
    entityKebabName,
    dbFunctionName,
    methodTypeName,
    methodParamsTypeName,
    clientMethodParamsTypeName,
    fetchParamsTypeName,
    hasAllParamsExpression,
    swrKeyConstantName,
    swrKeyBuilderExpression,
    sqlParamsExpression,
    methodParamsColumns,
    clientMethodParamsColumns,
    methodColumns,
    indexMethodParams,
    indexParamsColumns,
    indexTypeMethodName,
    indexMethodName,
    indexTypeName,
    indexColumns,
    sqlFunctionName,
    sqlParamsPlaceholders,
    apiPath,
    apiPathParams,
    generateMutation,
    mutationMergeOldData,
    compositeDefinitions,
    dateCreated,
    filesCreated,
    generatorName: "getMethodFetcher",
  }
}
