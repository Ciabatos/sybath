---
name: ai-doGatherResourcesOnMapTileAction-description
description: |
  Action doGatherResourcesOnMapTileAction description, workflow.

  Use when:
  When using action doGatherResourcesOnMapTileAction or trying to understand it.
---

# doGatherResourcesOnMapTileAction Action Documentation

# function path :`methods/actions/items/doGatherResourcesOnMapTileAction.ts`

# function doGatherResourcesOnMapTileAction(params: TDoGatherResourcesOnMapTileActionParams)

# TypeScript Types:

type TDoGatherResourcesOnMapTileActionParams = Omit<TDoGatherResourcesOnMapTileServiceParams, "sessionUserId"></T>

### Data Flow

```
# function doGatherResourcesOnMapTileService(params: TDoGatherResourcesOnMapTileServiceParams)
path: `methods/services/items/doGatherResourcesOnMapTileService.ts`
# TypeScript Types:

export type TDoGatherResourcesOnMapTileServiceParams = {
sessionUserId: number
playerId: number
}


 Database function doGatherResourcesOnMapTile(params: TDoGatherResourcesOnMapTileParams)
# path: `db/postgresMainDatabase/schemas/items/doGatherResourcesOnMapTile.ts`
# TypeScript Types:

export type TDoGatherResourcesOnMapTileParams = {
  playerId: number
  mapId: number
  x: number
  y: number
  mapTilesResourceId: number
  gatherAmount: number
}

export type TDoGatherResourcesOnMapTile = {
  status: boolean
  message: string
}

#### PostgreSQL Database
# "schema": "items"
# "method": "do_gather_resources_on_map_tile"
You have more information in mcp `game-db`
```

Note: doGatherResourcesOnMapTileAction is a Next.js Server Action A Next.js Server Action is a function that: Runs on
the server Can be called directly from a React component Is typically triggered by form submissions or user interactions
Eliminates the need for manual API endpoints
