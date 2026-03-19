import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { registerSchemaTools } from "./tools/schema.js";

// ─────────────────────────────────────────────────────────────────────────────
// Server setup
// ─────────────────────────────────────────────────────────────────────────────

const server = new McpServer({
  name: "rpg-db-mcp-server",
  version: "1.0.0",
});

// Register all schema-discovery tools
registerSchemaTools(server);

// ─────────────────────────────────────────────────────────────────────────────
// Transport — stdio (default) or streamable HTTP
// ─────────────────────────────────────────────────────────────────────────────

async function runStdio(): Promise<void> {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  process.stderr.write("[rpg-db-mcp] Server started on stdio\n");
}

async function runHttp(): Promise<void> {
  // Lazy import so the http path doesn't load express when using stdio
  const expressModule = await import("express");
  const express = expressModule.default;
  const { StreamableHTTPServerTransport } = await import(
    "@modelcontextprotocol/sdk/server/streamableHttp.js"
  );

  const app = express();
  app.use(express.json());

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  app.post("/mcp", async (req: any, res: any) => {
    const transport = new StreamableHTTPServerTransport({
      sessionIdGenerator: undefined,
      enableJsonResponse: true,
    });
    res.on("close", () => transport.close());
    await server.connect(transport);
    await transport.handleRequest(req, res, req.body);
  });

  const port = parseInt(process.env.PORT ?? "3000", 10);
  app.listen(port, () => {
    process.stderr.write(`[rpg-db-mcp] Server running on http://localhost:${port}/mcp\n`);
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

const transport = process.env.TRANSPORT ?? "stdio";

if (transport === "http") {
  runHttp().catch((err: unknown) => {
    process.stderr.write(`[rpg-db-mcp] Fatal error: ${err instanceof Error ? err.message : String(err)}\n`);
    process.exit(1);
  });
} else {
  runStdio().catch((err: unknown) => {
    process.stderr.write(`[rpg-db-mcp] Fatal error: ${err instanceof Error ? err.message : String(err)}\n`);
    process.exit(1);
  });
}
