---
name: ai-useFetchDistrictsDistrictTypesByKey-description
description: |
  Hook useFetchDistrictsDistrictTypesByKey description, workflow.

  Use when:
  When using hook useFetchDistrictsDistrictTypesByKey or trying to understand it.
---

# useFetchDistrictsDistrictTypesByKey hook Documentation

# function path :`methods/hooks/districts/core/useFetchDistrictsDistrictTypesByKey.ts`

# function useFetchDistrictsDistrictTypesByKey( params: TDistrictsDistrictTypesParams )

# Jotai atom name: const districtTypesAtom = atom<TDistrictsDistrictTypesRecordById>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams })
# path: `app/api/districts/district-types/[id]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  id: z.coerce.number(),
}) satisfies z.ZodType<TDistrictsDistrictTypesParams>

# function fetchDistrictsDistrictTypesByKeyService(params: TDistrictsDistrictTypesParams,options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/districts/fetchDistrictsDistrictTypesByKeyService.ts`
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

# function function getDistrictsDistrictTypesByKey(params: TDistrictsDistrictTypesParams)
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
# function path :`methods/hooks/districts/core/useMutateDistrictsDistrictTypesByKey.ts`
# function useMutateDistrictsDistrictTypes( params: TDistrictsDistrictTypesParams)

#### PostgreSQL Database
# "schema": "districts"
# "method": "get_district_types_by_key"
You have more information in mcp `game-db`
```
