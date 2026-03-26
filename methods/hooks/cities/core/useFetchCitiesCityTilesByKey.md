---
name: ai-useFetchCitiesCityTilesByKey-description
description: |
  Hook useFetchCitiesCityTilesByKey description, workflow.

  Use when:
  When using hook useFetchCitiesCityTilesByKey or trying to understand it.
---

# useFetchCitiesCityTilesByKey hook Documentation

# function path :`methods/hooks/cities/core/useFetchCitiesCityTilesByKey.ts`

# function useFetchCitiesCityTilesByKey( params: TCitiesCityTilesParams )

# Jotai atom name: const cityTilesAtom = atom<TCitiesCityTilesRecordByXY>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams })
# path: `app/api/cities/city-tiles/[cityId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  cityId: z.coerce.number(),
}) satisfies z.ZodType<TCitiesCityTilesParams>

# function fetchCitiesCityTilesByKeyService(params: TCitiesCityTilesParams,options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/cities/fetchCitiesCityTilesByKeyService.ts`
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

# function function getCitiesCityTilesByKey(params: TCitiesCityTilesParams)
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
# function path :`methods/hooks/cities/core/useMutateCitiesCityTilesByKey.ts`
# function useMutateCitiesCityTiles( params: TCitiesCityTilesParams)

#### PostgreSQL Database
# "schema": "cities"
# "method": "get_city_tiles_by_key"
You have more information in mcp `game-db`
```
