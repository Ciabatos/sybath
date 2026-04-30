import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js"
import { z } from "zod"
import { ALLOWED_API_TYPES, CHARACTER_LIMIT } from "../constants.js"
import { fetchAllFunctions, fetchFunctionDefinition, fetchFunctions, fetchTables } from "../services/db.js"
import type { AnyFunctionInfo, FunctionDefinitionInfo, FunctionInfo, TableInfo } from "../types.js"

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

function truncateIfNeeded(json: string): string {
  if (json.length <= CHARACTER_LIMIT) return json

  return (
    json.slice(0, CHARACTER_LIMIT) +
    `\n\n... [TRUNCATED — response exceeded ${CHARACTER_LIMIT.toLocaleString()} characters. ` +
    `Use the 'schema' filter parameter to narrow your query.]`
  )
}

// Lightweight: only table names grouped by schema — no columns
function formatTableNamesAsMarkdown(tables: TableInfo[]): string {
  if (tables.length === 0) return "_No tables found._"

  const bySchema = new Map<string, string[]>()
  for (const t of tables) {
    const list = bySchema.get(t.schema) ?? []
    list.push(t.table_name)
    bySchema.set(t.schema, list)
  }

  const lines: string[] = []
  for (const [schema, names] of bySchema) {
    lines.push(`**${schema}**: ${names.join(", ")}`)
  }
  return lines.join("\n")
}

// Full column details — used by get_tables
function formatTablesAsMarkdown(tables: TableInfo[]): string {
  if (tables.length === 0) return "_No tables found._"

  const lines: string[] = []

  for (const t of tables) {
    lines.push(`## ${t.schema}.${t.table_name}`)
    lines.push(`| Column | Type | Nullable | Default |`)
    lines.push(`|--------|------|----------|---------|`)
    for (const c of t.columns) {
      const nullable = c.is_nullable ? "YES" : "NO"
      const def = c.column_default ?? "—"
      lines.push(`| ${c.column_name} | ${c.data_type} | ${nullable} | ${def} |`)
    }
    lines.push("")
  }

  return lines.join("\n")
}

// Lightweight: only function names grouped by api_type — no arguments
function formatFunctionNamesAsMarkdown(fns: FunctionInfo[]): string {
  if (fns.length === 0) return "_No functions found._"

  const groups: Record<string, FunctionInfo[]> = {}
  for (const f of fns) {
    ;(groups[f.api_type] ??= []).push(f)
  }

  const labels: Record<string, string> = {
    automatic_get_api: "📋 automatic_get_api — dictionary / reference data",
    get_api: "🔍 get_api — player-context, fog-of-war aware",
    action_api: "⚡ action_api — modifies game state",
  }

  const lines: string[] = []
  for (const apiType of ALLOWED_API_TYPES) {
    const group = groups[apiType]
    if (!group?.length) continue

    lines.push(`**${labels[apiType]}** (${group.length})`)
    lines.push(group.map((f) => `\`${f.schema}.${f.function_name}\``).join(", "))
    lines.push("")
  }

  return lines.join("\n")
}

// Full argument details — used by get_functions
function formatFunctionsAsMarkdown(fns: FunctionInfo[]): string {
  if (fns.length === 0) return "_No functions found._"

  const groups: Record<string, FunctionInfo[]> = {}
  for (const f of fns) {
    ;(groups[f.api_type] ??= []).push(f)
  }

  const lines: string[] = []

  const labels: Record<string, string> = {
    automatic_get_api: "📋 Automatic GET (dictionary / reference data)",
    get_api: "🔍 GET (player-context data, fog-of-war aware)",
    action_api: "⚡ ACTION (modifies game state, may queue async tasks)",
  }

  for (const apiType of ALLOWED_API_TYPES) {
    const group = groups[apiType]
    if (!group?.length) continue

    lines.push(`## ${labels[apiType]}`)
    lines.push(`| Schema | Function | Arguments | Returns |`)
    lines.push(`|--------|----------|-----------|---------|`)
    for (const f of group) {
      lines.push(`| ${f.schema} | ${f.function_name} | ${f.arguments || "—"} | ${f.return_type} |`)
    }
    lines.push("")
  }

  return lines.join("\n")
}

// ─────────────────────────────────────────────────────────────────────────────
// Tool registration
// ─────────────────────────────────────────────────────────────────────────────

export function registerSchemaTools(server: McpServer): void {
  registerGetSchema(server)
  registerGetTables(server)
  registerGetFunctions(server)
  registerGetAllFunctions(server)
  registerGetFunctionDefinition(server)
}

// ── get_schema ────────────────────────────────────────────────────────────────
// Lightweight overview: table names + function names only. No columns, no args.
// Use get_tables / get_functions to drill into details.

const GetSchemaInputSchema = z
  .object({
    response_format: z
      .enum(["json", "markdown"])
      .default("markdown")
      .describe("Output format. 'markdown' is human-readable (default). 'json' returns structured data."),
  })
  .strict()

function registerGetSchema(server: McpServer): void {
  server.registerTool(
    "get_schema",
    {
      title: "Get Database Overview (Lightweight Map)",
      description: `Returns a compact overview of the RPG database: table names grouped by schema, and function names grouped by api_type.

This is intentionally lightweight — no column definitions, no function arguments.
Use it first to orient yourself, then drill into details with focused tools:
  - get_tables(schema)           → columns for a specific schema
  - get_functions(api_type)      → full argument list for a function group
  - get_function_definition(...) → full SQL source for a specific function

The database is divided into PostgreSQL schemas:
- attributes  — abilities, skills, stats, player progression
- auth        — users, sessions, OAuth accounts
- buildings   — building types and instances
- cities      — cities and city tiles
- districts   — districts within cities
- inventory   — containers, slots, items
- items       — item catalog and item stats
- knowledge   — fog-of-war: what each player knows
- players     — player characters
- squad       — player squads / parties
- tasks       — async task queue (scheduler jobs)
- world       — maps, tiles, terrain, regions, positions

Functions are annotated with one of three API types:
- automatic_get_api  Dictionary/reference data (terrain types, item catalog, etc.)
- get_api            Player-context data that respects fog-of-war
- action_api         Game actions that modify state

Args:
  - response_format ('markdown' | 'json'): Output format (default: 'markdown')

Returns:
  markdown: Table names grouped by schema + function names grouped by api_type
  json: { tables: { schema, table_name }[], functions: { schema, function_name, api_type }[] }`,
      inputSchema: GetSchemaInputSchema,
      annotations: {
        readOnlyHint: true,
        destructiveHint: false,
        idempotentHint: true,
        openWorldHint: false,
      },
    },
    async ({ response_format }) => {
      try {
        const [tables, functions] = await Promise.all([fetchTables(), fetchFunctions()])

        if (response_format === "json") {
          const output = {
            tables: tables.map(({ schema, table_name }) => ({ schema, table_name })),
            functions: functions.map(({ schema, function_name, api_type }) => ({ schema, function_name, api_type })),
          }
          const json = JSON.stringify(output, null, 2)
          return {
            content: [{ type: "text", text: truncateIfNeeded(json) }],
            structuredContent: output,
          }
        }

        const md = [
          "# RPG Database — Overview",
          "",
          `**Tables:** ${tables.length}   **API Functions:** ${functions.length}`,
          "",
          "> 💡 This is a lightweight map. Use `get_tables(schema)` for column details,",
          "> `get_functions(api_type)` for argument lists, `get_function_definition` for SQL source.",
          "",
          "---",
          "",
          "## Tables by Schema",
          "",
          formatTableNamesAsMarkdown(tables),
          "",
          "---",
          "",
          "## API Functions by Type",
          "",
          formatFunctionNamesAsMarkdown(functions),
        ].join("\n")

        return { content: [{ type: "text", text: truncateIfNeeded(md) }] }
      } catch (err) {
        return {
          content: [
            {
              type: "text",
              text: `Error querying database schema: ${err instanceof Error ? err.message : String(err)}`,
            },
          ],
          isError: true,
        }
      }
    },
  )
}

// ── get_tables ────────────────────────────────────────────────────────────────

const GetTablesInputSchema = z
  .object({
    schema: z
      .string()
      .optional()
      .describe(
        "Filter by PostgreSQL schema name, e.g. 'world', 'inventory', 'players'. " +
          "Omit to return tables from all schemas.",
      ),
    response_format: z
      .enum(["json", "markdown"])
      .default("markdown")
      .describe("Output format. 'markdown' (default) or 'json'."),
  })
  .strict()

function registerGetTables(server: McpServer): void {
  server.registerTool(
    "get_tables",
    {
      title: "Get Database Tables with Columns",
      description: `Returns tables with full column definitions from the RPG database.
Optionally filter to a single PostgreSQL schema.

Use this tool when you need to:
- Inspect the structure of a specific schema
- Find which columns a table has before building a query
- Understand data types and nullability constraints

Tip: call get_schema first to see which schemas exist, then drill in here.

Available schemas (never returns admin/util/system schemas):
  attributes, auth, buildings, cities, districts, inventory,
  items, knowledge, players, squad, tasks, world

Args:
  - schema (string, optional): Filter to one schema, e.g. 'world'. Omit for all.
  - response_format ('markdown' | 'json'): Output format (default: 'markdown')

Returns:
  A list of tables. Each table includes:
  - schema        PostgreSQL schema name
  - table_name    Table name
  - columns       Array of column definitions:
      - column_name     Name of the column
      - data_type       PostgreSQL data type (e.g. 'integer', 'character varying')
      - is_nullable     true if the column accepts NULL
      - column_default  Default expression or null if none

Examples:
  - "What columns does the players schema have?"
    → call with schema: 'players'
  - "Show me all world tables with their columns"
    → call with schema: 'world'
  - "Give me the full table list with all columns"
    → call with no schema filter`,
      inputSchema: GetTablesInputSchema,
      annotations: {
        readOnlyHint: true,
        destructiveHint: false,
        idempotentHint: true,
        openWorldHint: false,
      },
    },
    async ({ schema, response_format }) => {
      try {
        const tables = await fetchTables(schema ?? null)

        if (tables.length === 0) {
          const msg = schema
            ? `No tables found in schema '${schema}'. ` +
              `Valid schemas: attributes, auth, buildings, cities, districts, inventory, items, knowledge, players, squad, tasks, world`
            : "No tables found."
          return { content: [{ type: "text", text: msg }] }
        }

        if (response_format === "json") {
          const json = JSON.stringify(tables, null, 2)
          return {
            content: [{ type: "text", text: truncateIfNeeded(json) }],
            structuredContent: { tables },
          }
        }

        const header = schema
          ? `# Tables in schema \`${schema}\` (${tables.length})`
          : `# All Tables (${tables.length})`

        const md = [header, "", formatTablesAsMarkdown(tables)].join("\n")
        return { content: [{ type: "text", text: truncateIfNeeded(md) }] }
      } catch (err) {
        return {
          content: [
            {
              type: "text",
              text: `Error fetching tables: ${err instanceof Error ? err.message : String(err)}`,
            },
          ],
          isError: true,
        }
      }
    },
  )
}

// ── get_functions ─────────────────────────────────────────────────────────────

const GetFunctionsInputSchema = z
  .object({
    api_type: z
      .enum(["automatic_get_api", "get_api", "action_api"])
      .optional()
      .describe(
        "Filter by API type. " +
          "'automatic_get_api' = dictionary/reference data (terrain types, items, etc.). " +
          "'get_api' = player-context data respecting fog-of-war. " +
          "'action_api' = game actions that modify state. " +
          "Omit to return all three types.",
      ),
    schema: z
      .string()
      .optional()
      .describe("Filter by PostgreSQL schema, e.g. 'world', 'inventory'. Omit for all schemas."),
    response_format: z
      .enum(["json", "markdown"])
      .default("markdown")
      .describe("Output format. 'markdown' (default) or 'json'."),
  })
  .strict()

function registerGetFunctions(server: McpServer): void {
  server.registerTool(
    "get_functions",
    {
      title: "Get API Functions with Arguments",
      description: `Returns PostgreSQL functions exposed as the RPG game API, with full argument lists.
Optionally filter by api_type (function category) and/or schema.

Tip: call get_schema first to see function names, then use this tool when you need argument details.

Functions are annotated with one of three API types via a SQL comment:

  automatic_get_api
    Dictionary/reference data. Always-safe reads, no player context needed.
    Examples: get_terrain_types(), get_items(), get_abilities()
    Pattern: pairs of get_X() / get_X_by_key(p_id) for each reference table.

  get_api
    Player-context data. Requires at least p_player_id. Respects fog-of-war:
    unknown tiles/players return NULL fields instead of no rows.
    p_other_player_id is text — can be an integer ID or a UUID (masked_id).
    Examples: get_player_position(), get_known_map_tiles(), get_player_inventory()

  action_api
    Game actions that modify state. Always returns TABLE(status boolean, message text).
    Some actions queue async tasks in tasks.tasks instead of executing immediately.
    JSONB parameters (path, exploration, gather) are arrays of step objects.
    Examples: do_player_movement(), do_gather_resources_on_map_tile()

Args:
  - api_type ('automatic_get_api' | 'get_api' | 'action_api', optional): Filter by type.
  - schema (string, optional): Filter by schema, e.g. 'world'. Omit for all.
  - response_format ('markdown' | 'json'): Output format (default: 'markdown')

Returns:
  A list of functions. Each entry includes:
  - schema          PostgreSQL schema
  - function_name   Function name
  - arguments       Full argument list string (from pg_get_function_arguments)
  - return_type     Return type string (from pg_get_function_result)
  - api_type        One of: automatic_get_api | get_api | action_api

Examples:
  - "What actions can a player perform?"
    → call with api_type: 'action_api'
  - "What data can I read about the world map?"
    → call with api_type: 'get_api', schema: 'world'
  - "List all reference data functions"
    → call with api_type: 'automatic_get_api'`,
      inputSchema: GetFunctionsInputSchema,
      annotations: {
        readOnlyHint: true,
        destructiveHint: false,
        idempotentHint: true,
        openWorldHint: false,
      },
    },
    async ({ api_type, schema, response_format }) => {
      try {
        let functions = await fetchFunctions(api_type ?? null)

        if (schema) {
          functions = functions.filter((f) => f.schema === schema)
        }

        if (functions.length === 0) {
          const filters = [api_type ? `api_type='${api_type}'` : null, schema ? `schema='${schema}'` : null]
            .filter(Boolean)
            .join(", ")
          return {
            content: [
              {
                type: "text",
                text: `No API functions found${filters ? ` matching ${filters}` : ""}.`,
              },
            ],
          }
        }

        if (response_format === "json") {
          const json = JSON.stringify(functions, null, 2)
          return {
            content: [{ type: "text", text: truncateIfNeeded(json) }],
            structuredContent: { functions },
          }
        }

        const filterDesc = [
          api_type ? `type \`${api_type}\`` : "all types",
          schema ? `schema \`${schema}\`` : "all schemas",
        ].join(", ")

        const md = [
          `# API Functions — ${filterDesc} (${functions.length})`,
          "",
          formatFunctionsAsMarkdown(functions),
        ].join("\n")

        return { content: [{ type: "text", text: truncateIfNeeded(md) }] }
      } catch (err) {
        return {
          content: [
            {
              type: "text",
              text: `Error fetching functions: ${err instanceof Error ? err.message : String(err)}`,
            },
          ],
          isError: true,
        }
      }
    },
  )
}

// ── get_function_definition ───────────────────────────────────────────────────

function formatDefinitionsAsMarkdown(defs: FunctionDefinitionInfo[]): string {
  if (defs.length === 0) return "_No function found._"

  return defs
    .map((d) => {
      const header = [
        `## ${d.schema}.${d.function_name}`,
        `**Kind:** ${d.kind}   **Language:** ${d.language}   **Returns:** ${d.return_type}`,
        d.comment ? `**API type:** ${d.comment}` : null,
        "",
      ]
        .filter((l) => l !== null)
        .join("\n")

      return `${header}\n\`\`\`sql\n${d.definition}\n\`\`\``
    })
    .join("\n\n---\n\n")
}

const GetFunctionDefinitionInputSchema = z
  .object({
    schema: z.string().describe("PostgreSQL schema that owns the function, e.g. 'world', 'inventory', 'admin'."),
    function_name: z.string().describe("Exact function or procedure name, e.g. 'get_player_position'."),
    response_format: z
      .enum(["markdown", "json"])
      .default("markdown")
      .describe(
        "Output format. 'markdown' (default) renders the SQL in a fenced block. 'json' returns structured data.",
      ),
  })
  .strict()

function registerGetFunctionDefinition(server: McpServer): void {
  server.registerTool(
    "get_function_definition",
    {
      title: "Get Function SQL Definition",
      description: `Returns the full SQL source (CREATE OR REPLACE FUNCTION … $$ … $$) for a specific function or procedure.

Use this tool when you need to:
- Understand exactly what a function does before calling it
- Debug or audit business logic inside a stored function
- Check argument names, defaults, and SECURITY DEFINER / STRICT modifiers
- Inspect trigger functions or utility helpers

Handles overloaded functions — if multiple overloads share the same name, all are returned.

Args:
  - schema (string, required):        PostgreSQL schema, e.g. 'world', 'inventory', 'admin'
  - function_name (string, required): Exact function name, e.g. 'get_player_position'
  - response_format ('markdown' | 'json'): Output format (default: 'markdown')

Returns:
  markdown: Header with metadata + fenced SQL block per overload
  json: Array of FunctionDefinitionInfo:
    { schema, function_name, arguments, return_type, comment, kind, language, definition }

Examples:
  - "Show me what get_player_position does"
    → schema: 'world', function_name: 'get_player_position'
  - "What does the do_player_movement function actually execute?"
    → schema: 'world', function_name: 'do_player_movement'
  - "Show admin.create_player source"
    → schema: 'admin', function_name: 'create_player'`,
      inputSchema: GetFunctionDefinitionInputSchema,
      annotations: {
        readOnlyHint: true,
        destructiveHint: false,
        idempotentHint: true,
        openWorldHint: false,
      },
    },
    async ({ schema, function_name, response_format }) => {
      try {
        const defs = await fetchFunctionDefinition(schema, function_name)

        if (defs.length === 0) {
          return {
            content: [
              {
                type: "text",
                text: `No function '${schema}.${function_name}' found. Check the schema and function name — both are case-sensitive.`,
              },
            ],
          }
        }

        if (response_format === "json") {
          const json = JSON.stringify(defs, null, 2)
          return {
            content: [{ type: "text", text: truncateIfNeeded(json) }],
            structuredContent: { definitions: defs },
          }
        }

        const overloadNote = defs.length > 1 ? ` (${defs.length} overloads)` : ""
        const md = [
          `# Definition: ${schema}.${function_name}${overloadNote}`,
          "",
          formatDefinitionsAsMarkdown(defs),
        ].join("\n")

        return { content: [{ type: "text", text: truncateIfNeeded(md) }] }
      } catch (err) {
        return {
          content: [
            {
              type: "text",
              text: `Error fetching function definition: ${err instanceof Error ? err.message : String(err)}`,
            },
          ],
          isError: true,
        }
      }
    },
  )
}

// ── get_all_functions ─────────────────────────────────────────────────────────

function formatAllFunctionsAsMarkdown(fns: AnyFunctionInfo[]): string {
  if (fns.length === 0) return "_No functions found._"

  const bySchema = new Map<string, AnyFunctionInfo[]>()
  for (const f of fns) {
    const list = bySchema.get(f.schema) ?? []
    list.push(f)
    bySchema.set(f.schema, list)
  }

  const lines: string[] = []
  for (const [schema, group] of bySchema) {
    lines.push(`## Schema: ${schema} (${group.length})`)
    lines.push(`| Function | Kind | Language | Arguments | Returns | API Comment |`)
    lines.push(`|----------|------|----------|-----------|---------|-------------|`)
    for (const f of group) {
      const comment = f.comment ?? "—"
      lines.push(
        `| ${f.function_name} | ${f.kind} | ${f.language} | ${f.arguments || "—"} | ${f.return_type} | ${comment} |`,
      )
    }
    lines.push("")
  }

  return lines.join("\n")
}

const GetAllFunctionsInputSchema = z
  .object({
    schema: z
      .string()
      .optional()
      .describe(
        "Filter by PostgreSQL schema, e.g. 'world', 'admin', 'util'. Omit to return functions from all schemas.",
      ),
    search: z
      .string()
      .optional()
      .describe(
        "Case-insensitive substring search on function name, e.g. 'player' returns get_player_position, do_player_movement, etc.",
      ),
    response_format: z
      .enum(["json", "markdown"])
      .default("markdown")
      .describe("Output format. 'markdown' (default) or 'json'."),
  })
  .strict()

function registerGetAllFunctions(server: McpServer): void {
  server.registerTool(
    "get_all_functions",
    {
      title: "Get All Database Functions (No Restrictions)",
      description: `Returns ALL PostgreSQL functions and procedures from the database — including internal helpers, admin procedures, utility functions, and any function without an API comment.

Unlike get_functions (which only shows functions tagged automatic_get_api / get_api / action_api),
this tool has NO comment filter and includes every routine visible in pg_proc.

Includes schemas that get_functions excludes:
- admin   — map generation, player creation, reset procedures
- util    — internal helpers (raise_error, etc.)
- All other schemas: attributes, auth, buildings, cities, districts,
  inventory, items, knowledge, players, squad, tasks, world

Each result includes:
- schema          PostgreSQL schema
- function_name   Function / procedure name
- kind            'function' or 'procedure'
- language        Implementation language (plpgsql, sql, etc.)
- arguments       Full argument list (from pg_get_function_arguments)
- return_type     Return type (from pg_get_function_result)
- comment         SQL comment if set (e.g. 'automatic_get_api', 'get_api', 'action_api', or any custom comment), null if none

Args:
  - schema (string, optional): Filter to one schema, e.g. 'admin'. Omit for all.
  - search (string, optional): Case-insensitive substring match on function name, e.g. 'player'.
  - response_format ('markdown' | 'json'): Output format (default: 'markdown')

Examples:
  - "Show all admin procedures"
    → call with schema: 'admin'
  - "Find all functions related to movement"
    → call with search: 'movement'
  - "List every function in the util schema"
    → call with schema: 'util'
  - "What internal helpers exist for inventory?"
    → call with schema: 'inventory', search: 'check'`,
      inputSchema: GetAllFunctionsInputSchema,
      annotations: {
        readOnlyHint: true,
        destructiveHint: false,
        idempotentHint: true,
        openWorldHint: false,
      },
    },
    async ({ schema, search, response_format }) => {
      try {
        const functions = await fetchAllFunctions(schema ?? null, search ?? null)

        if (functions.length === 0) {
          const filters = [schema ? `schema='${schema}'` : null, search ? `search='${search}'` : null]
            .filter(Boolean)
            .join(", ")
          return {
            content: [
              {
                type: "text",
                text: `No functions found${filters ? ` matching ${filters}` : ""}.`,
              },
            ],
          }
        }

        if (response_format === "json") {
          const json = JSON.stringify(functions, null, 2)
          return {
            content: [{ type: "text", text: truncateIfNeeded(json) }],
            structuredContent: { functions },
          }
        }

        const filterDesc = [schema ? `schema \`${schema}\`` : "all schemas", search ? `search \`${search}\`` : null]
          .filter(Boolean)
          .join(", ")

        const md = [
          `# All Functions — ${filterDesc} (${functions.length})`,
          "",
          formatAllFunctionsAsMarkdown(functions),
        ].join("\n")

        return { content: [{ type: "text", text: truncateIfNeeded(md) }] }
      } catch (err) {
        return {
          content: [
            {
              type: "text",
              text: `Error fetching all functions: ${err instanceof Error ? err.message : String(err)}`,
            },
          ],
          isError: true,
        }
      }
    },
  )
}
