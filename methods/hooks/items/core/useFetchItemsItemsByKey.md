---
name: ai-useFetchItemsItemsByKey-description
description: |
  Hook useFetchItemsItemsByKey description, workflow.

  Use when:
  When using hook useFetchItemsItemsByKey or trying to understand it.
---

# useFetchItemsItemsByKey hook Documentation

# function path :`methods/hooks/items/core/useFetchItemsItemsByKey.ts`

# function useFetchItemsItemsByKey( params: TItemsItemsParams )

# Jotai atom name: const itemsAtom = atom<TItemsItemsRecordById>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams })
# path: `app/api/items/items/[id]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  id: z.coerce.number(),
}) satisfies z.ZodType<TItemsItemsParams>

# function fetchItemsItemsByKeyService(params: TItemsItemsParams,options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/items/fetchItemsItemsByKeyService.ts`
# TypeScript Types:

type TCacheRecord = {
  raw: TItemsItems[]
  byKey: TItemsItemsRecordById
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function function getItemsItemsByKey(params: TItemsItemsParams)
# path: `db/postgresMainDatabase/schemas/items/items.ts`
# TypeScript Types:

export type TItemsItemsParams = {
  id: number
}

export type TItemsItems = {
  id: number
  name?: string
  description?: string
  image: string
}

export type TItemsItemsRecordById = Record<string, TItemsItems>

Hook for mutate data using SWR
# function path :`methods/hooks/items/core/useMutateItemsItemsByKey.ts`
# function useMutateItemsItems( params: TItemsItemsParams)

#### PostgreSQL Database
# "schema": "items"
# "method": "get_items_by_key"
You have more information in mcp `game-db`
```
