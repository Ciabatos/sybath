---
name: ai-useFetchBuildingsBuildingTypesByKey-description
description: |
  Hook useFetchBuildingsBuildingTypesByKey description, workflow.

  Use when:
  When using hook useFetchBuildingsBuildingTypesByKey or trying to understand it.
---

# useFetchBuildingsBuildingTypesByKey hook Documentation

# function path :`methods/hooks/buildings/core/useFetchBuildingsBuildingTypesByKey.ts`

# function useFetchBuildingsBuildingTypesByKey( params: TBuildingsBuildingTypesParams )

# Jotai atom name: const buildingTypesAtom = atom<TBuildingsBuildingTypesRecordById>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams })
# path: `app/api/buildings/building-types/[id]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  id: z.coerce.number(),
}) satisfies z.ZodType<TBuildingsBuildingTypesParams>

# function fetchBuildingsBuildingTypesByKeyService(params: TBuildingsBuildingTypesParams,options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/buildings/fetchBuildingsBuildingTypesByKeyService.ts`
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

# function function getBuildingsBuildingTypesByKey(params: TBuildingsBuildingTypesParams)
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
# function path :`methods/hooks/buildings/core/useMutateBuildingsBuildingTypesByKey.ts`
# function useMutateBuildingsBuildingTypes( params: TBuildingsBuildingTypesParams)

#### PostgreSQL Database
# "schema": "buildings"
# "method": "get_building_types_by_key"
You have more information in mcp `game-db`
```
