---
name: ai-useFetchPlayerRecipeMaterials-description
description: |
  Hook useFetchPlayerRecipeMaterials description, workflow.

  Use when:
  When using hook useFetchPlayerRecipeMaterials or trying to understand it.
---

# useFetchPlayerRecipeMaterials hook Documentation

# function path :`methods/hooks/items/core/useFetchPlayerRecipeMaterials.ts`

# function useFetchPlayerRecipeMaterials( params: TPlayerRecipeMaterialsParams)

# Jotai atom name: const playerRecipeMaterialsAtom = atom<TPlayerRecipeMaterialsRecordById>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/items/rpc/get-player-recipe-materials/[playerId]/[recipeId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
  recipeId: z.coerce.number(),
}) satisfies z.ZodType<TPlayerRecipeMaterialsParams>

# function getPlayerRecipeMaterialsServer( params: TPlayerRecipeMaterialsParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/items/core/getPlayerRecipeMaterialsServer.ts`
# TypeScript Types:

type TResult = {
  raw: TPlayerRecipeMaterials[]
  byKey: TPlayerRecipeMaterialsRecordById
  apiPath: string
  atomName: string
}

# function getPlayerRecipeMaterials(params: TPlayerRecipeMaterialsParams)
# path: `db/postgresMainDatabase/schemas/items/playerRecipeMaterials.ts`
# TypeScript Types:

export type TPlayerRecipeMaterialsParams = {
  playerId: number
  recipeId: number
}

export type TPlayerRecipeMaterials = {
  id: number
  recipeId: number
  itemId: number
  quantity: number
  ownedQuantity: number
  missingQuantity: number
  canCraftMissing: boolean
}

export type TPlayerRecipeMaterialsRecordById = Record<string, TPlayerRecipeMaterials>

Hook for mutate data using SWR
# function path :`methods/hooks/items/core/useMutatePlayerRecipeMaterials.ts`
# function useMutatePlayerRecipeMaterials( params: TPlayerRecipeMaterialsParams)

#### PostgreSQL Database
# "schema": "items"
# "method": "get_player_recipe_materials"
You have more information in mcp `game-db`
```
