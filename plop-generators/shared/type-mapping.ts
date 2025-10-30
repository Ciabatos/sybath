const TYPE_MAP: Record<string, string> = {
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

export const mapSQLTypeToTS = (sqlType: string | null): string => {
  if (!sqlType) return "any"

  let cleanType = sqlType.trim().toLowerCase()

  // Array types: "integer[]" -> "number[]"
  if (cleanType.endsWith("[]")) {
    const baseType = cleanType.slice(0, -2).replace(/\([^)]*\)/g, "")
    const baseTsType = TYPE_MAP[baseType] || "any"
    return `${baseTsType}[]`
  }

  // Remove length/params: "varchar(255)" -> "varchar"
  cleanType = cleanType.replace(/\([^)]*\)/g, "")

  return TYPE_MAP[cleanType] || "any"
}

export interface FieldDefinition {
  name: string
  camelName: string
  pascalName?: string
  tsType: string
  optional?: string
}

export const createFieldDefinition = (
  name: string,
  sqlType: string,
  isNullable?: boolean
): FieldDefinition => {
  const camelName = name.replace(/^p_/, "").replace(/_([a-z])/g, (_, l) => l.toUpperCase())
  
  return {
    name,
    camelName,
    tsType: mapSQLTypeToTS(sqlType),
    optional: isNullable ? "?" : "",
  }
}
