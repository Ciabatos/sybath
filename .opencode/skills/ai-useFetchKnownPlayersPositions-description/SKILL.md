---
name: ai-useFetchKnownPlayersPositions-description
description: |
  Hook useFetchKnownPlayersPositions description, workflow.

  Use when:
  When using hook useFetchKnownPlayersPositions or trying to understand it.
---



# useFetchKnownPlayersPositions hook Documentation
# function path :`methods/hooks/world/core/useFetchKnownPlayersPositions.ts` 
# function useFetchKnownPlayersPositions( params: TKnownPlayersPositionsParams)
# Jotai atom name: const knownPlayersPositionsAtom = atom<TKnownPlayersPositionsRecordByXY>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/world/rpc/get-known-players-positions/[mapId]/[playerId]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  mapId: z.coerce.number(),
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TKnownPlayersPositionsParams>

# function getKnownPlayersPositionsServer( params: TKnownPlayersPositionsParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/world/core/getKnownPlayersPositionsServer.ts` 
# TypeScript Types:

type TResult = {
  raw: TKnownPlayersPositions[]
  byKey: TKnownPlayersPositionsRecordByXY
  apiPath: string
  atomName: string
}

# function getKnownPlayersPositions(params: TKnownPlayersPositionsParams)
# path: `db/postgresMainDatabase/schemas/world/knownPlayersPositions.ts` 
# TypeScript Types:

export type TKnownPlayersPositionsParams = {
  mapId: number
  playerId: number
}

export type TKnownPlayersPositions = {
  otherPlayerId: string
  x: number
  y: number
  imageMap: string
}

export type TKnownPlayersPositionsRecordByXY = Record<string, TKnownPlayersPositions>

Hook for mutate data using SWR
# function path :`methods/hooks/world/core/useMutateKnownPlayersPositions.ts` 
# function useMutateKnownPlayersPositions( params: TKnownPlayersPositionsParams)

#### PostgreSQL Database
# "schema": "world"
# "method": "get_known_players_positions"
You have more information in mcp `game-db`
```