---
name: ai-useFetchKnownMapTilesResourcesOnTile-description
description: |
  Hook useFetchKnownMapTilesResourcesOnTile description, workflow.

  Use when:
  When using hook useFetchKnownMapTilesResourcesOnTile or trying to understand it.
---

# useFetchKnownMapTilesResourcesOnTile hook Documentation

# function path :`methods/hooks/world/core/useFetchKnownMapTilesResourcesOnTile.ts`

# function useFetchKnownMapTilesResourcesOnTile( params: TKnownMapTilesResourcesOnTileParams)

# Jotai atom name: const knownMapTilesResourcesOnTileAtom = atom<TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/world/rpc/get-known-map-tiles-resources-on-tile/[mapId]/[mapTileX]/[mapTileY]/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  mapId: z.coerce.number(),
  mapTileX: z.coerce.number(),
  mapTileY: z.coerce.number(),
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TKnownMapTilesResourcesOnTileParams>

# function getKnownMapTilesResourcesOnTileServer( params: TKnownMapTilesResourcesOnTileParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/world/core/getKnownMapTilesResourcesOnTileServer.ts`
# TypeScript Types:

type TResult = {
  raw: TKnownMapTilesResourcesOnTile[]
  byKey: TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId
  apiPath: string
  atomName: string
}

# function getKnownMapTilesResourcesOnTile(params: TKnownMapTilesResourcesOnTileParams)
# path: `db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnTile.ts`
# TypeScript Types:

export type TKnownMapTilesResourcesOnTileParams = {
  mapId: number
  mapTileX: number
  mapTileY: number
  playerId: number
}

export type TKnownMapTilesResourcesOnTile = {
  mapTilesResourceId: number
  itemId: number
  quantity: number
}

export type TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId = Record<string, TKnownMapTilesResourcesOnTile>

Hook for mutate data using SWR
# function path :`methods/hooks/world/core/useMutateKnownMapTilesResourcesOnTile.ts`
# function useMutateKnownMapTilesResourcesOnTile( params: TKnownMapTilesResourcesOnTileParams)

#### PostgreSQL Database
# "schema": "world"
# "method": "get_known_map_tiles_resources_on_tile"
You have more information in mcp `game-db`
```
