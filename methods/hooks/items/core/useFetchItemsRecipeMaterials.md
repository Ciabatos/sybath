---
name: ai-useFetchItemsRecipeMaterials-description
description: |
  Hook useFetchItemsRecipeMaterials description, workflow.

  Use when:
  When using hook useFetchItemsRecipeMaterials or trying to understand it.
---

# useFetchItemsRecipeMaterials hook Documentation

# function path :`methods/hooks/items/core/useFetchItemsRecipeMaterials.ts`

# function function useFetchItemsRecipeMaterials()

# Jotai atom name: const recipeMaterialsAtom = atom<TItemsRecipeMaterialsRecordById>({})

### Data Flow

```
# function GET(request: NextRequest)
# path: `app/api/items/recipe-materials/route.ts`


# function fetchItemsRecipeMaterialsService(options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/items/fetchItemsRecipeMaterialsService.ts`
# TypeScript Types:

type TCacheRecord = {
  raw: TItemsRecipeMaterials[]
  byKey: TItemsRecipeMaterialsRecordById
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function getItemsRecipeMaterials()
# path: `db/postgresMainDatabase/schemas/items/recipeMaterials.ts`
# TypeScript Types:

export type TItemsRecipeMaterialsParams = {
  recipeId: number
}

export type TItemsRecipeMaterials = {
  id: number
  recipeId: number
  itemId: number
  quantity: number
}

export type TItemsRecipeMaterialsRecordById = Record<string, TItemsRecipeMaterials>

Hook for mutate data using SWR
# function path :`methods/hooks/items/core/useMutateItemsRecipeMaterials.ts`
# function useMutateItemsRecipeMaterials()

#### PostgreSQL Database
# "schema": "items"
# "method": "get_recipe_materials"
You have more information in mcp `game-db`
```
