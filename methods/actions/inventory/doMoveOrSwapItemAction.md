---
name: ai-doMoveOrSwapItemAction-description
description: |
  Action doMoveOrSwapItemAction description, workflow.

  Use when:
  When using action doMoveOrSwapItemAction or trying to understand it.
---

# doMoveOrSwapItemAction Action Documentation

# function path :`methods/actions/inventory/doMoveOrSwapItemAction.ts`

# function doMoveOrSwapItemAction(params: TDoMoveOrSwapItemActionParams)

# TypeScript Types:

type TDoMoveOrSwapItemActionParams = Omit<TDoMoveOrSwapItemServiceParams, "sessionUserId"></T>

### Data Flow

function doMoveOrSwapItemService(params: TDoMoveOrSwapItemServiceParams) path:
methods/services/inventory/doMoveOrSwapItemService.ts

TypeScript Types: export type TDoMoveOrSwapItemServiceParams = { sessionUserId: string playerId: number }

Database function doMoveOrSwapItem(params: TDoMoveOrSwapItemParams)

path: db/postgresMainDatabase/schemas/inventory/doMoveOrSwapItem.ts TypeScript Types:

export type TDoMoveOrSwapItemParams = { userId: string playerId: number fromSlotId: number toSlotId: number
fromInventoryContainerId: number toInventoryContainerId: number }

export type TDoMoveOrSwapItem = { status: boolean message: string }

PostgreSQL Database "schema": "inventory" "method": "do_move_or_swap_item" You have more information in mcp game-db
