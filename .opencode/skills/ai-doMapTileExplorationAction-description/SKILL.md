---
name: ai-doMapTileExplorationAction-description
description: |
  Action doMapTileExplorationAction description, workflow.

  Use when:
  When using action doMapTileExplorationAction or trying to understand it.
---



# doMapTileExplorationAction Action Documentation
# function path :`methods/actions/world/doMapTileExplorationAction.ts` 
# function doMapTileExplorationAction(params: TDoMapTileExplorationActionParams)
# TypeScript Types:
type TDoMapTileExplorationActionParams = Omit<TDoMapTileExplorationServiceParams, "sessionUserId"></T>

### Data Flow
```
# function doMapTileExplorationService(params: TDoMapTileExplorationServiceParams)
path: `methods/services/world/doMapTileExplorationService.ts` 
# TypeScript Types:

export type TDoMapTileExplorationServiceParams = {
sessionUserId: number
playerId: number
}


 Database function doMapTileExploration(params: TDoMapTileExplorationParams) 
# path: `db/postgresMainDatabase/schemas/world/doMapTileExploration.ts` 
# TypeScript Types:

export type TDoMapTileExplorationParams = {
  playerId: number
  parameters: any
}

export type TDoMapTileExploration = {
  status: boolean
  message: string
}

#### PostgreSQL Database
# "schema": "world"
# "method": "do_map_tile_exploration"
You have more information in mcp `game-db`
```

Note: doMapTileExplorationAction is a Next.js Server Action
A Next.js Server Action is a function that:
Runs on the server
Can be called directly from a React component
Is typically triggered by form submissions or user interactions
Eliminates the need for manual API endpoints