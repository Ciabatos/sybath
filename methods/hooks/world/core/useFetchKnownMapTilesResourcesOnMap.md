---
name: ai-useFetchKnownMapTilesResourcesOnMap-description
description: |
  Hook useFetchKnownMapTilesResourcesOnMap description, workflow.

  Use when:
  When using hook useFetchKnownMapTilesResourcesOnMap or trying to understand it.
---

# useFetchKnownMapTilesResourcesOnMap hook Documentation

# function path :`methods/hooks/world/core/useFetchKnownMapTilesResourcesOnMap.ts`

# function useFetchKnownMapTilesResourcesOnMap( params: TKnownMapTilesResourcesOnMapParams)

# Jotai atom name: const knownMapTilesResourcesOnMapAtom = atom<TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/world/rpc/get-known-map-tiles-resources-on-map/[mapId]/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  mapId: z.coerce.number(),
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TKnownMapTilesResourcesOnMapParams>

# function getKnownMapTilesResourcesOnMapServer( params: TKnownMapTilesResourcesOnMapParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/world/core/getKnownMapTilesResourcesOnMapServer.ts`
# TypeScript Types:

type TResult = {
  raw: TKnownMapTilesResourcesOnMap[]
  byKey: TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY
  apiPath: string
  atomName: string
}

# function getKnownMapTilesResourcesOnMap(params: TKnownMapTilesResourcesOnMapParams)
# path: `db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnMap.ts`
# TypeScript Types:

export type TKnownMapTilesResourcesOnMapParams = {
  mapId: number
  playerId: number
}

export type TCtItemIds = {
  itemId: number
}

export type TKnownMapTilesResourcesOnMap = {
  mapTileX: number
  mapTileY: number
  itemIds: TCtItemIds[]
}

export type TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY = Record<string, TKnownMapTilesResourcesOnMap>

Hook for mutate data using SWR
# function path :`methods/hooks/world/core/useMutateKnownMapTilesResourcesOnMap.ts`
# function useMutateKnownMapTilesResourcesOnMap( params: TKnownMapTilesResourcesOnMapParams)

#### PostgreSQL Database
# "schema": "world"
# "method": "get_known_map_tiles_resources_on_map"
You have more information in mcp `game-db`
```
