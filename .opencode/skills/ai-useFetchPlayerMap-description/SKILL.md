---
name: ai-useFetchPlayerMap-description
description: |
  Hook useFetchPlayerMap description, workflow.

  Use when:
  When using hook useFetchPlayerMap or trying to understand it.
---



# useFetchPlayerMap hook Documentation
# function path :`methods/hooks/world/core/useFetchPlayerMap.ts` 
# function useFetchPlayerMap( params: TPlayerMapParams)
# Jotai atom name: const playerMapAtom = atom<TPlayerMapRecordByMapId>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/world/rpc/get-player-map/[playerId]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TPlayerMapParams>

# function getPlayerMapServer( params: TPlayerMapParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/world/core/getPlayerMapServer.ts` 
# TypeScript Types:

type TResult = {
  raw: TPlayerMap[]
  byKey: TPlayerMapRecordByMapId
  apiPath: string
  atomName: string
}

# function getPlayerMap(params: TPlayerMapParams)
# path: `db/postgresMainDatabase/schemas/world/playerMap.ts` 
# TypeScript Types:

export type TPlayerMapParams = {
  playerId: number
}

export type TPlayerMap = {
  mapId: number
}

export type TPlayerMapRecordByMapId = Record<string, TPlayerMap>

Hook for mutate data using SWR
# function path :`methods/hooks/world/core/useMutatePlayerMap.ts` 
# function useMutatePlayerMap( params: TPlayerMapParams)

#### PostgreSQL Database
# "schema": "world"
# "method": "get_player_map"
You have more information in mcp `game-db`
```