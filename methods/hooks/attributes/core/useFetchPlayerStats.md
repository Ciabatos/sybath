---
name: ai-useFetchPlayerStats-description
description: |
  Hook useFetchPlayerStats description, workflow.

  Use when:
  When using hook useFetchPlayerStats or trying to understand it.
---

# useFetchPlayerStats hook Documentation

# function path :`methods/hooks/attributes/core/useFetchPlayerStats.ts`

# function useFetchPlayerStats( params: TPlayerStatsParams)

# Jotai atom name: const playerStatsAtom = atom<TPlayerStatsRecordByStatId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/attributes/rpc/get-player-stats/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TPlayerStatsParams>

# function getPlayerStatsServer( params: TPlayerStatsParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/attributes/core/getPlayerStatsServer.ts`
# TypeScript Types:

type TResult = {
  raw: TPlayerStats[]
  byKey: TPlayerStatsRecordByStatId
  apiPath: string
  atomName: string
}

# function getPlayerStats(params: TPlayerStatsParams)
# path: `db/postgresMainDatabase/schemas/attributes/playerStats.ts`
# TypeScript Types:

export type TPlayerStatsParams = {
  playerId: number
}

export type TPlayerStats = {
  statId: number
  value: number
  name: string
}

export type TPlayerStatsRecordByStatId = Record<string, TPlayerStats>

Hook for mutate data using SWR
# function path :`methods/hooks/attributes/core/useMutatePlayerStats.ts`
# function useMutatePlayerStats( params: TPlayerStatsParams)

#### PostgreSQL Database
# "schema": "attributes"
# "method": "get_player_stats"
You have more information in mcp `game-db`
```
