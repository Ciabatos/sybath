---
name: ai-useFetchItemsItems-description
description: |
  Hook useFetchItemsItems description, workflow.

  Use when:
  When using hook useFetchItemsItems or trying to understand it.
---

# useFetchItemsItems hook Documentation

# function path :`methods/hooks/items/core/useFetchItemsItems.ts`

# function function useFetchItemsItems()

# Jotai atom name: const itemsAtom = atom<TItemsItemsRecordById>({})

### Data Flow

```
# function GET(request: NextRequest)
# path: `app/api/items/items/route.ts`


# function fetchItemsItemsService(options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/items/fetchItemsItemsService.ts`
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

# function getItemsItems()
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
# function path :`methods/hooks/items/core/useMutateItemsItems.ts`
# function useMutateItemsItems()

#### PostgreSQL Database
# "schema": "items"
# "method": "get_items"
You have more information in mcp `game-db`
```
