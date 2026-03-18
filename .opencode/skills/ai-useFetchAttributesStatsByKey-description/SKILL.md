---
name: ai-useFetchAttributesStatsByKey-description
description: |
  Hook useFetchAttributesStatsByKey description, workflow.

  Use when:
  When using hook useFetchAttributesStatsByKey or trying to understand it.
---



# useFetchAttributesStatsByKey hook Documentation
# function path :`methods/hooks/attributes/core/useFetchAttributesStatsByKey.ts` 
# function useFetchAttributesStatsByKey( params: TAttributesStatsParams )
# Jotai atom name: const statsAtom = atom<TAttributesStatsRecordById>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams })
# path: `app/api/attributes/stats/[id]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  id: z.coerce.number(),
}) satisfies z.ZodType<TAttributesStatsParams>

# function fetchAttributesStatsByKeyService(params: TAttributesStatsParams,options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/attributes/fetchAttributesStatsByKeyService.ts` 
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

# function function getAttributesStatsByKey(params: TAttributesStatsParams)
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
# function path :`methods/hooks/attributes/core/useMutateAttributesStatsByKey.ts` 
# function useMutateAttributesStats( params: TAttributesStatsParams)

#### PostgreSQL Database
# "schema": "attributes"
# "method": "get_stats_by_key"
You have more information in mcp `game-db`
```