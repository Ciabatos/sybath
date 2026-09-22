---
name: ai-doAddItemToInventoryAction-description
description: |
  Action doAddItemToInventoryAction description, workflow.

  Use when:
  When using action doAddItemToInventoryAction or trying to understand it.
---

# doAddItemToInventoryAction Action Documentation

# function path :`methods/actions/inventory/doAddItemToInventoryAction.ts`

# function doAddItemToInventoryAction(params: TDoAddItemToInventoryActionParams)

# TypeScript Types:

type TDoAddItemToInventoryActionParams = Omit<TDoAddItemToInventoryServiceParams, "sessionUserId"></T>

### Data Flow

function doAddItemToInventoryService(params: TDoAddItemToInventoryServiceParams) path:
methods/services/inventory/doAddItemToInventoryService.ts

TypeScript Types: export type TDoAddItemToInventoryServiceParams = { sessionUserId: string playerId: number }

Database function doAddItemToInventory(params: TDoAddItemToInventoryParams)

path: db/postgresMainDatabase/schemas/inventory/doAddItemToInventory.ts TypeScript Types:

export type TDoAddItemToInventoryParams = { userId: string inventoryContainerId: number itemId: number quantity: number
}

export type TDoAddItemToInventory = { status: boolean message: string }

PostgreSQL Database "schema": "inventory" "method": "do_add_item_to_inventory" You have more information in mcp game-db
