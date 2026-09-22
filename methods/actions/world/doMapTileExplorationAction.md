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

function doMapTileExplorationService(params: TDoMapTileExplorationServiceParams) path:
methods/services/world/doMapTileExplorationService.ts

TypeScript Types: export type TDoMapTileExplorationServiceParams = { sessionUserId: string playerId: number }

Database function doMapTileExploration(params: TDoMapTileExplorationParams)

path: db/postgresMainDatabase/schemas/world/doMapTileExploration.ts TypeScript Types:

export type TDoMapTileExplorationParams = { userId: string playerId: number mapId: number x: number y: number
explorationLevel: number }

export type TDoMapTileExploration = { status: boolean message: string }

PostgreSQL Database "schema": "world" "method": "do_map_tile_exploration" You have more information in mcp game-db
