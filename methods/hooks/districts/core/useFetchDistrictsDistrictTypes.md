---
name: ai-useFetchDistrictsDistrictTypes-description
description: |
  Hook useFetchDistrictsDistrictTypes description, workflow.

  Use when:
  When using hook useFetchDistrictsDistrictTypes or trying to understand it.
---

# useFetchDistrictsDistrictTypes hook Documentation

# function path :`methods/hooks/districts/core/useFetchDistrictsDistrictTypes.ts`

# function function useFetchDistrictsDistrictTypes()

# Jotai atom name: const districtTypesAtom = atom<TDistrictsDistrictTypesRecordById>({})

### Data Flow

```
# function GET(request: NextRequest)
# path: `app/api/districts/district-types/route.ts`


# function fetchDistrictsDistrictTypesService(options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/districts/fetchDistrictsDistrictTypesService.ts`
# TypeScript Types:

type TCacheRecord = {
  raw: TDistrictsDistrictTypes[]
  byKey: TDistrictsDistrictTypesRecordById
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function getDistrictsDistrictTypes()
# path: `db/postgresMainDatabase/schemas/districts/districtTypes.ts`
# TypeScript Types:

export type TDistrictsDistrictTypesParams = {
  id: number
}

export type TDistrictsDistrictTypes = {
  id: number
  name: string
  moveCost: number
  imageUrl?: string
}

export type TDistrictsDistrictTypesRecordById = Record<string, TDistrictsDistrictTypes>

Hook for mutate data using SWR
# function path :`methods/hooks/districts/core/useMutateDistrictsDistrictTypes.ts`
# function useMutateDistrictsDistrictTypes()

#### PostgreSQL Database
# "schema": "districts"
# "method": "get_district_types"
You have more information in mcp `game-db`
```
