---
name: ai-useFetchBuildingsBuildings-description
description: |
  Hook useFetchBuildingsBuildings description, workflow.

  Use when:
  When using hook useFetchBuildingsBuildings or trying to understand it.
---



# useFetchBuildingsBuildings hook Documentation
# function path :`methods/hooks/buildings/core/useFetchBuildingsBuildings.ts` 
# function function useFetchBuildingsBuildings()
# Jotai atom name: const buildingsAtom = atom<TBuildingsBuildingsRecordByCityTileXCityTileY>({})


### Data Flow
```
# function GET(request: NextRequest)
# path: `app/api/buildings/buildings/route.ts` 


# function fetchBuildingsBuildingsService(options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult> 
# path: `methods/services/buildings/fetchBuildingsBuildingsService.ts` 
# TypeScript Types:

type TCacheRecord = {
  raw: TBuildingsBuildings[]
  byKey: TBuildingsBuildingsRecordByCityTileXCityTileY
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function getBuildingsBuildings()
# path: `db/postgresMainDatabase/schemas/buildings/buildings.ts` 
# TypeScript Types:

export type TBuildingsBuildingsParams = {
  cityId: number
}

export type TBuildingsBuildings = {
  id: number
  cityId: number
  cityTileX: number
  cityTileY: number
  buildingTypeId: number
  name: string
}

export type TBuildingsBuildingsRecordByCityTileXCityTileY = Record<string, TBuildingsBuildings>

Hook for mutate data using SWR
# function path :`methods/hooks/buildings/core/useMutateBuildingsBuildings.ts` 
# function useMutateBuildingsBuildings()

#### PostgreSQL Database
# "schema": "buildings"
# "method": "get_buildings"
You have more information in mcp `game-db`
```