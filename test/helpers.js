export const typeMap = {
  // Numeric
  integer: "number",
  bigint: "number",
  smallint: "number",
  numeric: "number",
  decimal: "number",
  "double precision": "number",
  real: "number",
  serial: "number",
  bigserial: "number",
  // Boolean
  boolean: "boolean",
  // String
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
  // Other
  json: "any",
  jsonb: "jsonb",
  uuid: "string",
  bytea: "Buffer",
}

export const snakeToCamel = (s) => s.replace(/^p_/, "").replace(/_([a-z])/g, (_, c) => c.toUpperCase())
export const snakeToPascal = (s) => s.replace(/(^|_)([a-z])/g, (_, __, c) => c.toUpperCase())
export const camelToKebab = (s) => s.replace(/([a-z0-9])([A-Z])/g, "$1-$2").toLowerCase()
export const snakeToKebab = (s) => s.replace(/_/g, "-")
export const stripPrefix = (s) => (s.includes("_") ? s.slice(s.indexOf("_") + 1) : s)

export function mapSQLTypeToTS(sqlType) {
  if (!sqlType) return "any"
  const clean = sqlType
    .trim()
    .toLowerCase()
    .replace(/\([^)]*\)/g, "")
  if (clean.endsWith("[]")) return `${typeMap[clean.slice(0, -2)] ?? "any"}[]`
  return typeMap[clean] ?? "any"
}
