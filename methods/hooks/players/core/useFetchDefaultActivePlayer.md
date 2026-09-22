---
name: ai-useFetchDefaultActivePlayer-description
description: |
  Hook useFetchDefaultActivePlayer description, workflow.

  Use when:
  When using hook useFetchDefaultActivePlayer or trying to understand it.
---

# useFetchDefaultActivePlayer hook Documentation

# function path :`methods/hooks/players/core/useFetchDefaultActivePlayer.ts`

# function useFetchDefaultActivePlayer( params: TDefaultActivePlayerParams)

# Jotai atom name: const defaultActivePlayerAtom = atom<TDefaultActivePlayerRecordById>({})

### Data Flow

function GET(request: NextRequest, { params }: { params: TApiParams } ) path:
app/api/players/rpc/get-default-active-player/route.ts TypeScript Types: type TApiParams = Record<string, string>

const typeParamsSchema = z.object({ userId: z.coerce.string(), }) satisfies z.ZodType<TDefaultActivePlayerParams>

function getDefaultActivePlayerServer( params: TDefaultActivePlayerParams, options?: { forceFresh?: boolean },):
Promise<TResult> path: methods/server-fetchers/players/core/getDefaultActivePlayerServer.ts TypeScript Types: type
TResult = { raw: TDefaultActivePlayer[] byKey: TDefaultActivePlayerRecordById apiPath: string atomName: string }

function getDefaultActivePlayer(params: TDefaultActivePlayerParams) path:
db/postgresMainDatabase/schemas/players/defaultActivePlayer.ts TypeScript Types: export type TDefaultActivePlayerParams
= { userId: string }

export type TDefaultActivePlayer = { id: number }

export type TDefaultActivePlayerRecordById = Record<string, TDefaultActivePlayer>

Hook for mutate data using SWR

function path :methods/hooks/players/core/useMutateDefaultActivePlayer.ts function useMutateDefaultActivePlayer( params:
TDefaultActivePlayerParams) PostgreSQL Database "schema": "players" "method": "get_default_active_player" You have more
information in mcp game-db
