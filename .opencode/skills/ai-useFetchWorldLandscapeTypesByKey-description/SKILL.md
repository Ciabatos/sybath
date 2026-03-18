---
name: ai-useFetchWorldLandscapeTypesByKey-description
description: |
  Hook useFetchWorldLandscapeTypesByKey description, workflow.

  Use when:
  When using hook useFetchWorldLandscapeTypesByKey or trying to understand it.
---



# useFetchWorldLandscapeTypesByKey hook Documentation
# function path :`methods/hooks/world/core/useFetchWorldLandscapeTypesByKey.ts` 
# function useFetchWorldLandscapeTypesByKey( params: TWorldLandscapeTypesParams )
# Jotai atom name: const landscapeTypesAtom = atom<TWorldLandscapeTypesRecordById>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams })
# path: `app/api/world/landscape-types/[id]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  id: z.coerce.number(),
}) satisfies z.ZodType<TWorldLandscapeTypesParams>

# function fetchWorldLandscapeTypesByKeyService(params: TWorldLandscapeTypesParams,options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/world/fetchWorldLandscapeTypesByKeyService.ts` 
# TypeScript Types:

type TCacheRecord = {
  raw: TWorldLandscapeTypes[]
  byKey: TWorldLandscapeTypesRecordById
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function function getWorldLandscapeTypesByKey(params: TWorldLandscapeTypesParams)
# path: `db/postgresMainDatabase/schemas/world/landscapeTypes.ts` 
# TypeScript Types:

export type TWorldLandscapeTypesParams = {
  id: number
}

export type TWorldLandscapeTypes = {
  id: number
  name: string
  moveCost: number
  imageUrl?: string
}

export type TWorldLandscapeTypesRecordById = Record<string, TWorldLandscapeTypes>

Hook for mutate data using SWR
# function path :`methods/hooks/world/core/useMutateWorldLandscapeTypesByKey.ts` 
# function useMutateWorldLandscapeTypes( params: TWorldLandscapeTypesParams)

#### PostgreSQL Database
# "schema": "world"
# "method": "get_landscape_types_by_key"
You have more information in mcp `game-db`
```