---
name: ai-useFetchWorldMapTiles-description
description: |
  Hook useFetchWorldMapTiles description, workflow.

  Use when:
  When using hook useFetchWorldMapTiles or trying to understand it.
---

# useFetchWorldMapTiles hook Documentation

# function path :`methods/hooks/world/core/useFetchWorldMapTiles.ts`

# function function useFetchWorldMapTiles()

# Jotai atom name: const mapTilesAtom = atom<TWorldMapTilesRecordByXY>({})

### Data Flow

```
# function GET(request: NextRequest)
# path: `app/api/world/map-tiles/route.ts`


# function fetchWorldMapTilesService(options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/world/fetchWorldMapTilesService.ts`
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

# function getWorldMapTiles()
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
# function path :`methods/hooks/world/core/useMutateWorldMapTiles.ts`
# function useMutateWorldMapTiles()

#### PostgreSQL Database
# "schema": "world"
# "method": "get_map_tiles"
You have more information in mcp `game-db`
```
