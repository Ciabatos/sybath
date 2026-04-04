---
name: ai-useFetchPlayerRecipes-description
description: |
  Hook useFetchPlayerRecipes description, workflow.

  Use when:
  When using hook useFetchPlayerRecipes or trying to understand it.
---

# useFetchPlayerRecipes hook Documentation

# function path :`methods/hooks/items/core/useFetchPlayerRecipes.ts`

# function useFetchPlayerRecipes( params: TPlayerRecipesParams)

# Jotai atom name: const playerRecipesAtom = atom<TPlayerRecipesRecordByItemId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/items/rpc/get-player-recipes/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TPlayerRecipesParams>

# function getPlayerRecipesServer( params: TPlayerRecipesParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/items/core/getPlayerRecipesServer.ts`
# TypeScript Types:

type TResult = {
  raw: TPlayerRecipes[]
  byKey: TPlayerRecipesRecordByItemId
  apiPath: string
  atomName: string
}

# function getPlayerRecipes(params: TPlayerRecipesParams)
# path: `db/postgresMainDatabase/schemas/items/playerRecipes.ts`
# TypeScript Types:

export type TPlayerRecipesParams = {
  playerId: number
}

export type TPlayerRecipes = {
  id: number
  itemId: number
  description: string
  image: string
  skillId: number
  value: number
  canCraft: boolean
}

export type TPlayerRecipesRecordByItemId = Record<string, TPlayerRecipes>

Hook for mutate data using SWR
# function path :`methods/hooks/items/core/useMutatePlayerRecipes.ts`
# function useMutatePlayerRecipes( params: TPlayerRecipesParams)

#### PostgreSQL Database
# "schema": "items"
# "method": "get_player_recipes"
You have more information in mcp `game-db`
```
