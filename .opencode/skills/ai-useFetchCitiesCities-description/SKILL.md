---
name: ai-useFetchCitiesCities-description
description: |
  Hook useFetchCitiesCities description, workflow.

  Use when:
  When using hook useFetchCitiesCities or trying to understand it.
---



# useFetchCitiesCities hook Documentation
# function path :`methods/hooks/cities/core/useFetchCitiesCities.ts` 
# function function useFetchCitiesCities()
# Jotai atom name: const citiesAtom = atom<TCitiesCitiesRecordByMapTileXMapTileY>({})


### Data Flow
```
# function GET(request: NextRequest)
# path: `app/api/cities/cities/route.ts` 


# function fetchCitiesCitiesService(options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult> 
# path: `methods/services/cities/fetchCitiesCitiesService.ts` 
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

# function getCitiesCities()
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
# function path :`methods/hooks/cities/core/useMutateCitiesCities.ts` 
# function useMutateCitiesCities()

#### PostgreSQL Database
# "schema": "cities"
# "method": "get_cities"
You have more information in mcp `game-db`
```