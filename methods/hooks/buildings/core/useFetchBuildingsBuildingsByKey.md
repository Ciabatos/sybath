---
name: ai-useFetchBuildingsBuildingsByKey-description
description: |
  Hook useFetchBuildingsBuildingsByKey description, workflow.

  Use when:
  When using hook useFetchBuildingsBuildingsByKey or trying to understand it.
---

# useFetchBuildingsBuildingsByKey hook Documentation

# function path :`methods/hooks/buildings/core/useFetchBuildingsBuildingsByKey.ts`

# function useFetchBuildingsBuildingsByKey( params: TBuildingsBuildingsParams )

# Jotai atom name: const buildingsAtom = atom<TBuildingsBuildingsRecordByCityTileXCityTileY>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams })
# path: `app/api/buildings/buildings/[cityId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  cityId: z.coerce.number(),
}) satisfies z.ZodType<TBuildingsBuildingsParams>

# function fetchBuildingsBuildingsByKeyService(params: TBuildingsBuildingsParams,options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/buildings/fetchBuildingsBuildingsByKeyService.ts`
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

# function function getBuildingsBuildingsByKey(params: TBuildingsBuildingsParams)
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
# function path :`methods/hooks/buildings/core/useMutateBuildingsBuildingsByKey.ts`
# function useMutateBuildingsBuildings( params: TBuildingsBuildingsParams)

#### PostgreSQL Database
# "schema": "buildings"
# "method": "get_buildings_by_key"
You have more information in mcp `game-db`
```
