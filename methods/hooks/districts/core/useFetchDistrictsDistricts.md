---
name: ai-useFetchDistrictsDistricts-description
description: |
  Hook useFetchDistrictsDistricts description, workflow.

  Use when:
  When using hook useFetchDistrictsDistricts or trying to understand it.
---

# useFetchDistrictsDistricts hook Documentation

# function path :`methods/hooks/districts/core/useFetchDistrictsDistricts.ts`

# function function useFetchDistrictsDistricts()

# Jotai atom name: const districtsAtom = atom<TDistrictsDistrictsRecordByMapTileXMapTileY>({})

### Data Flow

```
# function GET(request: NextRequest)
# path: `app/api/districts/districts/route.ts`


# function fetchDistrictsDistrictsService(options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/districts/fetchDistrictsDistrictsService.ts`
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

# function getDistrictsDistricts()
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
# function path :`methods/hooks/districts/core/useMutateDistrictsDistricts.ts`
# function useMutateDistrictsDistricts()

#### PostgreSQL Database
# "schema": "districts"
# "method": "get_districts"
You have more information in mcp `game-db`
```
