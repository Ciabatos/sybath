---
name: ai-useFetchCitiesCityTiles-description
description: |
  Hook useFetchCitiesCityTiles description, workflow.

  Use when:
  When using hook useFetchCitiesCityTiles or trying to understand it.
---

# useFetchCitiesCityTiles hook Documentation

# function path :`methods/hooks/cities/core/useFetchCitiesCityTiles.ts`

# function function useFetchCitiesCityTiles()

# Jotai atom name: const cityTilesAtom = atom<TCitiesCityTilesRecordByXY>({})

### Data Flow

```
# function GET(request: NextRequest)
# path: `app/api/cities/city-tiles/route.ts`


# function fetchCitiesCityTilesService(options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/cities/fetchCitiesCityTilesService.ts`
# TypeScript Types:

type TCacheRecord = {
  raw: TCitiesCityTiles[]
  byKey: TCitiesCityTilesRecordByXY
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function getCitiesCityTiles()
# path: `db/postgresMainDatabase/schemas/cities/cityTiles.ts`
# TypeScript Types:

export type TCitiesCityTilesParams = {
  cityId: number
}

export type TCitiesCityTiles = {
  cityId: number
  x: number
  y: number
  terrainTypeId: number
  landscapeTypeId?: number
}

export type TCitiesCityTilesRecordByXY = Record<string, TCitiesCityTiles>

Hook for mutate data using SWR
# function path :`methods/hooks/cities/core/useMutateCitiesCityTiles.ts`
# function useMutateCitiesCityTiles()

#### PostgreSQL Database
# "schema": "cities"
# "method": "get_city_tiles"
You have more information in mcp `game-db`
```
