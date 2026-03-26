---
name: ai-useFetchBuildingsBuildingTypes-description
description: |
  Hook useFetchBuildingsBuildingTypes description, workflow.

  Use when:
  When using hook useFetchBuildingsBuildingTypes or trying to understand it.
---

# useFetchBuildingsBuildingTypes hook Documentation

# function path :`methods/hooks/buildings/core/useFetchBuildingsBuildingTypes.ts`

# function function useFetchBuildingsBuildingTypes()

# Jotai atom name: const buildingTypesAtom = atom<TBuildingsBuildingTypesRecordById>({})

### Data Flow

```
# function GET(request: NextRequest)
# path: `app/api/buildings/building-types/route.ts`


# function fetchBuildingsBuildingTypesService(options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/buildings/fetchBuildingsBuildingTypesService.ts`
# TypeScript Types:

type TCacheRecord = {
  raw: TBuildingsBuildingTypes[]
  byKey: TBuildingsBuildingTypesRecordById
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function getBuildingsBuildingTypes()
# path: `db/postgresMainDatabase/schemas/buildings/buildingTypes.ts`
# TypeScript Types:

export type TBuildingsBuildingTypesParams = {
  id: number
}

export type TBuildingsBuildingTypes = {
  id: number
  name: string
  imageUrl?: string
}

export type TBuildingsBuildingTypesRecordById = Record<string, TBuildingsBuildingTypes>

Hook for mutate data using SWR
# function path :`methods/hooks/buildings/core/useMutateBuildingsBuildingTypes.ts`
# function useMutateBuildingsBuildingTypes()

#### PostgreSQL Database
# "schema": "buildings"
# "method": "get_building_types"
You have more information in mcp `game-db`
```
