---
name: ai-useFetchKnownMapTiles-description
description: |
  Hook useFetchKnownMapTiles description, workflow.

  Use when:
  When using hook useFetchKnownMapTiles or trying to understand it.
---



# useFetchKnownMapTiles hook Documentation
# function path :`methods/hooks/world/core/useFetchKnownMapTiles.ts` 
# function useFetchKnownMapTiles( params: TKnownMapTilesParams)
# Jotai atom name: const knownMapTilesAtom = atom<TKnownMapTilesRecordByXY>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/world/rpc/get-known-map-tiles/[mapId]/[playerId]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  mapId: z.coerce.number(),
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TKnownMapTilesParams>

# function getKnownMapTilesServer( params: TKnownMapTilesParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/world/core/getKnownMapTilesServer.ts` 
# TypeScript Types:

type TResult = {
  raw: TKnownMapTiles[]
  byKey: TKnownMapTilesRecordByXY
  apiPath: string
  atomName: string
}

# function getKnownMapTiles(params: TKnownMapTilesParams)
# path: `db/postgresMainDatabase/schemas/world/knownMapTiles.ts` 
# TypeScript Types:

export type TKnownMapTilesParams = {
  mapId: number
  playerId: number
}

export type TKnownMapTiles = {
  mapId: number
  x: number
  y: number
  terrainTypeId: number
  landscapeTypeId: number
}

export type TKnownMapTilesRecordByXY = Record<string, TKnownMapTiles>

Hook for mutate data using SWR
# function path :`methods/hooks/world/core/useMutateKnownMapTiles.ts` 
# function useMutateKnownMapTiles( params: TKnownMapTilesParams)

#### PostgreSQL Database
# "schema": "world"
# "method": "get_known_map_tiles"
You have more information in mcp `game-db`
```