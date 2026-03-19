// ─────────────────────────────────────────────────────────────────────────────
// Types for schema discovery tools
// ─────────────────────────────────────────────────────────────────────────────

export interface ColumnInfo {
  column_name: string;
  data_type: string;
  is_nullable: boolean;
  column_default: string | null;
}

export interface TableInfo {
  schema: string;
  table_name: string;
  columns: ColumnInfo[];
}

export interface FunctionInfo {
  schema: string;
  function_name: string;
  arguments: string;
  return_type: string;
  api_type: "automatic_get_api" | "get_api" | "action_api";
}

export type ApiType = "automatic_get_api" | "get_api" | "action_api";

// Raw row returned by sqlGetTables query (one row per column)
export interface RawTableRow {
  table_schema: string;
  table_name: string;
  column_name: string;
  data_type: string;
  is_nullable: string; // 'YES' | 'NO' from information_schema
  column_default: string | null;
}

// Raw row returned by sqlGetFunctions query
export interface RawFunctionRow {
  schema: string;
  function_name: string;
  arguments: string;
  return_type: string;
  comment: ApiType;
}

/** Full function definition including SQL source body */
export interface FunctionDefinitionInfo {
  schema: string;
  function_name: string;
  arguments: string;
  return_type: string;
  comment: string | null;
  kind: "function" | "procedure";
  language: string;
  definition: string;
}

// Raw row returned by SQL_GET_FUNCTION_DEFINITION query
export interface RawFunctionDefinitionRow {
  schema: string;
  function_name: string;
  arguments: string;
  return_type: string;
  comment: string | null;
  kind: string;
  language: string;
  definition: string;
}
export interface AnyFunctionInfo {
  schema: string;
  function_name: string;
  arguments: string;
  return_type: string;
  comment: string | null;
  kind: "function" | "procedure";
  language: string;
}

// Raw row returned by sqlGetAllFunctions query
export interface RawAnyFunctionRow {
  schema: string;
  function_name: string;
  arguments: string;
  return_type: string;
  comment: string | null;
  kind: string;
  language: string;
}
