---
name: ai-useFetchCitiesCitiesByKey-description
description: |
  Hook useFetchCitiesCitiesByKey description, workflow.

  Use when:
  When using hook useFetchCitiesCitiesByKey or trying to understand it.
---

# useFetchCitiesCitiesByKey hook Documentation

# function path :`methods/hooks/cities/core/useFetchCitiesCitiesByKey.ts`

# function useFetchCitiesCitiesByKey( params: TCitiesCitiesParams )

# Jotai atom name: const citiesAtom = atom<TCitiesCitiesRecordByMapTileXMapTileY>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams })
# path: `app/api/cities/cities/[mapId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  mapId: z.coerce.number(),
}) satisfies z.ZodType<TCitiesCitiesParams>

# function fetchCitiesCitiesByKeyService(params: TCitiesCitiesParams,options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/cities/fetchCitiesCitiesByKeyService.ts`
# TypeScript Types:

type TCacheRecord = {
  raw: TCitiesCities[]
  byKey: TCitiesCitiesRecordByMapTileXMapTileY
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function function getCitiesCitiesByKey(params: TCitiesCitiesParams)
# path: `db/postgresMainDatabase/schemas/cities/cities.ts`
# TypeScript Types:

export type TCitiesCitiesParams = {
  mapId: number
}

export type TCitiesCities = {
  id: number
  mapId: number
  mapTileX: number
  mapTileY: number
  name: string
  moveCost: number
  imageUrl?: string
}

export type TCitiesCitiesRecordByMapTileXMapTileY = Record<string, TCitiesCities>

Hook for mutate data using SWR
# function path :`methods/hooks/cities/core/useMutateCitiesCitiesByKey.ts`
# function useMutateCitiesCities( params: TCitiesCitiesParams)

#### PostgreSQL Database
# "schema": "cities"
# "method": "get_cities_by_key"
You have more information in mcp `game-db`
```
