---
name: ai-doAddItemToPlayerInventoryAction-description
description: |
  Action doAddItemToPlayerInventoryAction description, workflow.

  Use when:
  When using action doAddItemToPlayerInventoryAction or trying to understand it.
---



# doAddItemToPlayerInventoryAction Action Documentation
# function path :`methods/actions/inventory/doAddItemToPlayerInventoryAction.ts` 
# function doAddItemToPlayerInventoryAction(params: TDoAddItemToPlayerInventoryActionParams)
# TypeScript Types:
type TDoAddItemToPlayerInventoryActionParams = Omit<TDoAddItemToPlayerInventoryServiceParams, "sessionUserId"></T>

### Data Flow
function doAddItemToPlayerInventoryService(params: TDoAddItemToPlayerInventoryServiceParams)
path: methods/services/inventory/doAddItemToPlayerInventoryService.ts

TypeScript Types:
export type TDoAddItemToPlayerInventoryServiceParams = {
sessionUserId: string
playerId: number
}

Database function doAddItemToPlayerInventory(params: TDoAddItemToPlayerInventoryParams)

path: db/postgresMainDatabase/schemas/inventory/doAddItemToPlayerInventory.ts
TypeScript Types:

export type TDoAddItemToPlayerInventoryParams = {
userId: string
playerId: number
itemId: number
quantity: number
}

export type TDoAddItemToPlayerInventory = {
status: boolean
message: string
}

PostgreSQL Database
"schema": "inventory"
"method": "do_add_item_to_player_inventory"
You have more information in mcp game-db