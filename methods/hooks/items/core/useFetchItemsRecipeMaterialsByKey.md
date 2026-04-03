---
name: ai-useFetchItemsRecipeMaterialsByKey-description
description: |
  Hook useFetchItemsRecipeMaterialsByKey description, workflow.

  Use when:
  When using hook useFetchItemsRecipeMaterialsByKey or trying to understand it.
---

# useFetchItemsRecipeMaterialsByKey hook Documentation

# function path :`methods/hooks/items/core/useFetchItemsRecipeMaterialsByKey.ts`

# function useFetchItemsRecipeMaterialsByKey( params: TItemsRecipeMaterialsParams )

# Jotai atom name: const recipeMaterialsAtom = atom<TItemsRecipeMaterialsRecordByRecipeId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams })
# path: `app/api/items/recipe-materials/[recipeId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  recipeId: z.coerce.number(),
}) satisfies z.ZodType<TItemsRecipeMaterialsParams>

# function fetchItemsRecipeMaterialsByKeyService(params: TItemsRecipeMaterialsParams,options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/items/fetchItemsRecipeMaterialsByKeyService.ts`
# TypeScript Types:

type TCacheRecord = {
  raw: TItemsRecipeMaterials[]
  byKey: TItemsRecipeMaterialsRecordByRecipeId
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function function getItemsRecipeMaterialsByKey(params: TItemsRecipeMaterialsParams)
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

export type TItemsRecipeMaterialsRecordByRecipeId = Record<string, TItemsRecipeMaterials>

Hook for mutate data using SWR
# function path :`methods/hooks/items/core/useMutateItemsRecipeMaterialsByKey.ts`
# function useMutateItemsRecipeMaterials( params: TItemsRecipeMaterialsParams)

#### PostgreSQL Database
# "schema": "items"
# "method": "get_recipe_materials_by_key"
You have more information in mcp `game-db`
```
