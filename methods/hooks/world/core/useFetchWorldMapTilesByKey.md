---
name: ai-useFetchWorldMapTilesByKey-description
description: |
  Hook useFetchWorldMapTilesByKey description, workflow.

  Use when:
  When using hook useFetchWorldMapTilesByKey or trying to understand it.
---

# useFetchWorldMapTilesByKey hook Documentation

# function path :`methods/hooks/world/core/useFetchWorldMapTilesByKey.ts`

# function useFetchWorldMapTilesByKey( params: TWorldMapTilesParams )

# Jotai atom name: const mapTilesAtom = atom<TWorldMapTilesRecordByXY>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams })
# path: `app/api/world/map-tiles/[mapId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  mapId: z.coerce.number(),
}) satisfies z.ZodType<TWorldMapTilesParams>

# function fetchWorldMapTilesByKeyService(params: TWorldMapTilesParams,options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/world/fetchWorldMapTilesByKeyService.ts`
# TypeScript Types:

type TCacheRecord = {
  raw: TWorldMapTiles[]
  byKey: TWorldMapTilesRecordByXY
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function function getWorldMapTilesByKey(params: TWorldMapTilesParams)
# path: `db/postgresMainDatabase/schemas/world/mapTiles.ts`
# TypeScript Types:

export type TWorldMapTilesParams = {
  mapId: number
}

export type TWorldMapTiles = {
  mapId: number
  x: number
  y: number
  terrainTypeId: number
  landscapeTypeId?: number
}

export type TWorldMapTilesRecordByXY = Record<string, TWorldMapTiles>

Hook for mutate data using SWR
# function path :`methods/hooks/world/core/useMutateWorldMapTilesByKey.ts`
# function useMutateWorldMapTiles( params: TWorldMapTilesParams)

#### PostgreSQL Database
# "schema": "world"
# "method": "get_map_tiles_by_key"
You have more information in mcp `game-db`
```
