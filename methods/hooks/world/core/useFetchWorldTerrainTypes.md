---
name: ai-useFetchWorldTerrainTypes-description
description: |
  Hook useFetchWorldTerrainTypes description, workflow.

  Use when:
  When using hook useFetchWorldTerrainTypes or trying to understand it.
---

# useFetchWorldTerrainTypes hook Documentation

# function path :`methods/hooks/world/core/useFetchWorldTerrainTypes.ts`

# function function useFetchWorldTerrainTypes()

# Jotai atom name: const terrainTypesAtom = atom<TWorldTerrainTypesRecordById>({})

### Data Flow

```
# function GET(request: NextRequest)
# path: `app/api/world/terrain-types/route.ts`


# function fetchWorldTerrainTypesService(options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/world/fetchWorldTerrainTypesService.ts`
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

# function getWorldTerrainTypes()
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
# function path :`methods/hooks/world/core/useMutateWorldTerrainTypes.ts`
# function useMutateWorldTerrainTypes()

#### PostgreSQL Database
# "schema": "world"
# "method": "get_terrain_types"
You have more information in mcp `game-db`
```
