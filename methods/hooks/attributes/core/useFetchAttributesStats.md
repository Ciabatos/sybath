---
name: ai-useFetchAttributesStats-description
description: |
  Hook useFetchAttributesStats description, workflow.

  Use when:
  When using hook useFetchAttributesStats or trying to understand it.
---

# useFetchAttributesStats hook Documentation

# function path :`methods/hooks/attributes/core/useFetchAttributesStats.ts`

# function function useFetchAttributesStats()

# Jotai atom name: const statsAtom = atom<TAttributesStatsRecordById>({})

### Data Flow

```
# function GET(request: NextRequest)
# path: `app/api/attributes/stats/route.ts`


# function fetchAttributesStatsService(options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/attributes/fetchAttributesStatsService.ts`
# TypeScript Types:

type TCacheRecord = {
  raw: TAttributesStats[]
  byKey: TAttributesStatsRecordById
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function getAttributesStats()
# path: `db/postgresMainDatabase/schemas/attributes/stats.ts`
# TypeScript Types:

export type TAttributesStatsParams = {
  id: number
}

export type TAttributesStats = {
  id: number
  name?: string
  description?: string
  image: string
}

export type TAttributesStatsRecordById = Record<string, TAttributesStats>

Hook for mutate data using SWR
# function path :`methods/hooks/attributes/core/useMutateAttributesStats.ts`
# function useMutateAttributesStats()

#### PostgreSQL Database
# "schema": "attributes"
# "method": "get_stats"
You have more information in mcp `game-db`
```
