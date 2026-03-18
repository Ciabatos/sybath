---
name: ai-useFetchDistrictsDistrictsByKey-description
description: |
  Hook useFetchDistrictsDistrictsByKey description, workflow.

  Use when:
  When using hook useFetchDistrictsDistrictsByKey or trying to understand it.
---



# useFetchDistrictsDistrictsByKey hook Documentation
# function path :`methods/hooks/districts/core/useFetchDistrictsDistrictsByKey.ts` 
# function useFetchDistrictsDistrictsByKey( params: TDistrictsDistrictsParams )
# Jotai atom name: const districtsAtom = atom<TDistrictsDistrictsRecordByMapTileXMapTileY>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams })
# path: `app/api/districts/districts/[mapId]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  mapId: z.coerce.number(),
}) satisfies z.ZodType<TDistrictsDistrictsParams>

# function fetchDistrictsDistrictsByKeyService(params: TDistrictsDistrictsParams,options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/districts/fetchDistrictsDistrictsByKeyService.ts` 
# TypeScript Types:

type TCacheRecord = {
  raw: TDistrictsDistricts[]
  byKey: TDistrictsDistrictsRecordByMapTileXMapTileY
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function function getDistrictsDistrictsByKey(params: TDistrictsDistrictsParams)
# path: `db/postgresMainDatabase/schemas/districts/districts.ts` 
# TypeScript Types:

export type TDistrictsDistrictsParams = {
  mapId: number
}

export type TDistrictsDistricts = {
  id: number
  mapId: number
  mapTileX: number
  mapTileY: number
  districtTypeId: number
  name?: string
}

export type TDistrictsDistrictsRecordByMapTileXMapTileY = Record<string, TDistrictsDistricts>

Hook for mutate data using SWR
# function path :`methods/hooks/districts/core/useMutateDistrictsDistrictsByKey.ts` 
# function useMutateDistrictsDistricts( params: TDistrictsDistrictsParams)

#### PostgreSQL Database
# "schema": "districts"
# "method": "get_districts_by_key"
You have more information in mcp `game-db`
```