---
name: ai-useFetchWorldTerrainTypesByKey-description
description: |
  Hook useFetchWorldTerrainTypesByKey description, workflow.

  Use when:
  When using hook useFetchWorldTerrainTypesByKey or trying to understand it.
---



# useFetchWorldTerrainTypesByKey hook Documentation
# function path :`methods/hooks/world/core/useFetchWorldTerrainTypesByKey.ts` 
# function useFetchWorldTerrainTypesByKey( params: TWorldTerrainTypesParams )
# Jotai atom name: const terrainTypesAtom = atom<TWorldTerrainTypesRecordById>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams })
# path: `app/api/world/terrain-types/[id]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  id: z.coerce.number(),
}) satisfies z.ZodType<TWorldTerrainTypesParams>

# function fetchWorldTerrainTypesByKeyService(params: TWorldTerrainTypesParams,options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/world/fetchWorldTerrainTypesByKeyService.ts` 
# TypeScript Types:

type TCacheRecord = {
  raw: TWorldTerrainTypes[]
  byKey: TWorldTerrainTypesRecordById
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function function getWorldTerrainTypesByKey(params: TWorldTerrainTypesParams)
# path: `db/postgresMainDatabase/schemas/world/terrainTypes.ts` 
# TypeScript Types:

export type TWorldTerrainTypesParams = {
  id: number
}

export type TWorldTerrainTypes = {
  id: number
  name: string
  moveCost: number
  imageUrl?: string
}

export type TWorldTerrainTypesRecordById = Record<string, TWorldTerrainTypes>

Hook for mutate data using SWR
# function path :`methods/hooks/world/core/useMutateWorldTerrainTypesByKey.ts` 
# function useMutateWorldTerrainTypes( params: TWorldTerrainTypesParams)

#### PostgreSQL Database
# "schema": "world"
# "method": "get_terrain_types_by_key"
You have more information in mcp `game-db`
```