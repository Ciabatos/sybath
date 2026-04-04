---
name: ai-doCraftRecipeAction-description
description: |
  Action doCraftRecipeAction description, workflow.

  Use when:
  When using action doCraftRecipeAction or trying to understand it.
---

# doCraftRecipeAction Action Documentation

# function path :`methods/actions/items/doCraftRecipeAction.ts`

# function doCraftRecipeAction(params: TDoCraftRecipeActionParams)

# TypeScript Types:

type TDoCraftRecipeActionParams = Omit<TDoCraftRecipeServiceParams, "sessionUserId"></T>

### Data Flow

```
# function doCraftRecipeService(params: TDoCraftRecipeServiceParams)
path: `methods/services/items/doCraftRecipeService.ts`
# TypeScript Types:

export type TDoCraftRecipeServiceParams = {
sessionUserId: number
playerId: number
}


 Database function doCraftRecipe(params: TDoCraftRecipeParams)
# path: `db/postgresMainDatabase/schemas/items/doCraftRecipe.ts`
# TypeScript Types:

export type TDoCraftRecipeParams = {
  playerId: number
  recipeId: number
}

export type TDoCraftRecipe = {
  status: boolean
  message: string
}

#### PostgreSQL Database
# "schema": "items"
# "method": "do_craft_recipe"
You have more information in mcp `game-db`
```

Note: doCraftRecipeAction is a Next.js Server Action A Next.js Server Action is a function that: Runs on the server Can
be called directly from a React component Is typically triggered by form submissions or user interactions Eliminates the
need for manual API endpoints
