---
name: ai-doPlayerMovementAction-description
description: |
  Action doPlayerMovementAction description, workflow.

  Use when:
  When using action doPlayerMovementAction or trying to understand it.
---

# doPlayerMovementAction Action Documentation

# function path :`methods/actions/world/doPlayerMovementAction.ts`

# function doPlayerMovementAction(params: TDoPlayerMovementActionParams)

# TypeScript Types:

type TDoPlayerMovementActionParams = Omit<TDoPlayerMovementServiceParams, "sessionUserId"></T>

### Data Flow

function doPlayerMovementService(params: TDoPlayerMovementServiceParams) path:
methods/services/world/doPlayerMovementService.ts

TypeScript Types: export type TDoPlayerMovementServiceParams = { sessionUserId: string playerId: number }

Database function doPlayerMovement(params: TDoPlayerMovementParams)

path: db/postgresMainDatabase/schemas/world/doPlayerMovement.ts TypeScript Types: export type TCtPath = { order: number
mapId: number x: number y: number totalMoveCost: number }

export type TDoPlayerMovementParams = { userId: string playerId: number path: TCtPath[] }

export type TDoPlayerMovement = { status: boolean message: string }

PostgreSQL Database "schema": "world" "method": "do_player_movement" You have more information in mcp game-db
