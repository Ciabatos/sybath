---
name: ai-useFetchOtherPlayerStats-description
description: |
  Hook useFetchOtherPlayerStats description, workflow.

  Use when:
  When using hook useFetchOtherPlayerStats or trying to understand it.
---

# useFetchOtherPlayerStats hook Documentation

# function path :`methods/hooks/attributes/core/useFetchOtherPlayerStats.ts`

# function useFetchOtherPlayerStats( params: TOtherPlayerStatsParams)

# Jotai atom name: const otherPlayerStatsAtom = atom<TOtherPlayerStatsRecordByStatId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/attributes/rpc/get-other-player-stats/[playerId]/[otherPlayerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
  otherPlayerId: z.coerce.string(),
}) satisfies z.ZodType<TOtherPlayerStatsParams>

# function getOtherPlayerStatsServer( params: TOtherPlayerStatsParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/attributes/core/getOtherPlayerStatsServer.ts`
# TypeScript Types:

type TResult = {
  raw: TOtherPlayerStats[]
  byKey: TOtherPlayerStatsRecordByStatId
  apiPath: string
  atomName: string
}

# function getOtherPlayerStats(params: TOtherPlayerStatsParams)
# path: `db/postgresMainDatabase/schemas/attributes/otherPlayerStats.ts`
# TypeScript Types:

export type TOtherPlayerStatsParams = {
  playerId: number
  otherPlayerId: string
}

export type TOtherPlayerStats = {
  statId: number
  value: number
  name: string
}

export type TOtherPlayerStatsRecordByStatId = Record<string, TOtherPlayerStats>

Hook for mutate data using SWR
# function path :`methods/hooks/attributes/core/useMutateOtherPlayerStats.ts`
# function useMutateOtherPlayerStats( params: TOtherPlayerStatsParams)

#### PostgreSQL Database
# "schema": "attributes"
# "method": "get_other_player_stats"
You have more information in mcp `game-db`
```
