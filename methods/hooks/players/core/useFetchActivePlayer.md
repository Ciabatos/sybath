---
name: ai-useFetchActivePlayer-description
description: |
  Hook useFetchActivePlayer description, workflow.

  Use when:
  When using hook useFetchActivePlayer or trying to understand it.
---

# useFetchActivePlayer hook Documentation

# function path :`methods/hooks/players/core/useFetchActivePlayer.ts`

# function useFetchActivePlayer( params: TActivePlayerParams)

# Jotai atom name: const activePlayerAtom = atom<TActivePlayerRecordById>({})

### Data Flow

function GET(request: NextRequest, { params }: { params: TApiParams } ) path:
app/api/players/rpc/get-active-player/route.ts TypeScript Types: type TApiParams = Record<string, string>

const typeParamsSchema = z.object({ userId: z.coerce.string(), }) satisfies z.ZodType<TActivePlayerParams>

function getActivePlayerServer( params: TActivePlayerParams, options?: { forceFresh?: boolean },): Promise<TResult>
path: methods/server-fetchers/players/core/getActivePlayerServer.ts TypeScript Types: type TResult = { raw:
TActivePlayer[] byKey: TActivePlayerRecordById apiPath: string atomName: string }

function getActivePlayer(params: TActivePlayerParams) path: db/postgresMainDatabase/schemas/players/activePlayer.ts
TypeScript Types: export type TActivePlayerParams = { userId: string }

export type TActivePlayer = { id: number }

export type TActivePlayerRecordById = Record<string, TActivePlayer>

Hook for mutate data using SWR

function path :methods/hooks/players/core/useMutateActivePlayer.ts function useMutateActivePlayer( params:
TActivePlayerParams) PostgreSQL Database "schema": "players" "method": "get_active_player" You have more information in
mcp game-db
