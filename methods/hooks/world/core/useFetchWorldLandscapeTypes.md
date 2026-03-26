---
name: ai-useFetchWorldLandscapeTypes-description
description: |
  Hook useFetchWorldLandscapeTypes description, workflow.

  Use when:
  When using hook useFetchWorldLandscapeTypes or trying to understand it.
---

# useFetchWorldLandscapeTypes hook Documentation

# function path :`methods/hooks/world/core/useFetchWorldLandscapeTypes.ts`

# function function useFetchWorldLandscapeTypes()

# Jotai atom name: const landscapeTypesAtom = atom<TWorldLandscapeTypesRecordById>({})

### Data Flow

```
# function GET(request: NextRequest)
# path: `app/api/world/landscape-types/route.ts`


# function fetchWorldLandscapeTypesService(options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/world/fetchWorldLandscapeTypesService.ts`
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

# function getWorldLandscapeTypes()
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
# function path :`methods/hooks/world/core/useMutateWorldLandscapeTypes.ts`
# function useMutateWorldLandscapeTypes()

#### PostgreSQL Database
# "schema": "world"
# "method": "get_landscape_types"
You have more information in mcp `game-db`
```
