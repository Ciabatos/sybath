export const typeMap = {
  integer: "number",
  bigint: "number",
  smallint: "number",
  numeric: "number",
  decimal: "number",
  "double precision": "number",
  real: "number",
  serial: "number",
  bigserial: "number",
  boolean: "boolean",
  text: "string",
  "character varying": "string",
  character: "string",
  varchar: "string",
  date: "string",
  timestamp: "string",
  "timestamp without time zone": "string",
  "timestamp with time zone": "string",
  timestamptz: "string",
  time: "string",
  json: "any",
  jsonb: "any",
  uuid: "string",
  bytea: "Buffer",
}

export function snakeToCamel(str) {
  return str.replace(/^p_/, "").replace(/_([a-z])/g, (_, letter) => letter.toUpperCase())
}

export function snakeToPascal(str) {
  return str.replace(/(^|_)([a-z])/g, (_, __, c) => c.toUpperCase())
}

export function camelToKebab(str) {
  return str.replace(/([a-z0-9])([A-Z])/g, "$1-$2").toLowerCase()
}

export function snakeToKebab(snake) {
  return snake.replace(/_/g, "-")
}

export function mapSQLTypeToTS(sqlType) {
  if (!sqlType) return "any"
  let cleanType = sqlType.trim().toLowerCase()
  if (cleanType.endsWith("[]")) {
    const baseType = cleanType.slice(0, -2).replace(/\([^)]*\)/g, "")
    return `${typeMap[baseType] || "any"}[]`
  }
  cleanType = cleanType.replace(/\([^)]*\)/g, "")
  return typeMap[cleanType] || "any"
}

export function getArgsArray(argsStr) {
  if (!argsStr) return []
  return argsStr
    .split(",")
    .map((arg) => {
      const trimmed = arg.trim()
      const spaceIndex = trimmed.indexOf(" ")
      return spaceIndex === -1 ? trimmed : trimmed.substring(0, spaceIndex)
    })
    .filter(Boolean)
}

export function parseParamsFields(argsStr) {
  if (!argsStr) return []
  return argsStr
    .split(",")
    .map((arg) => {
      const trimmed = arg.trim()
      const spaceIndex = trimmed.indexOf(" ")
      if (spaceIndex === -1) return null
      const name = trimmed.substring(0, spaceIndex)
      const sqlType = trimmed.substring(spaceIndex + 1)
      return {
        name,
        camelName: snakeToCamel(name),
        tsType: mapSQLTypeToTS(sqlType),
      }
    })
    .filter(Boolean)
}

export function stripPrefix(methodName) {
  const index = methodName.indexOf("_")
  if (index === -1) return methodName // brak podkreślenia, zwróć cały string
  return methodName.slice(index + 1) // zwróć wszystko po pierwszym '_'
}
