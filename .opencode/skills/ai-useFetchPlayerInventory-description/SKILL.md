---
name: ai-useFetchPlayerInventory-description
description: |
  Hook useFetchPlayerInventory description, workflow.

  Use when:
  When using hook useFetchPlayerInventory or trying to understand it.
---



# useFetchPlayerInventory hook Documentation
# function path :`methods/hooks/inventory/core/useFetchPlayerInventory.ts` 
# function useFetchPlayerInventory( params: TPlayerInventoryParams)
# Jotai atom name: const playerInventoryAtom = atom<TPlayerInventoryRecordBySlotId>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/inventory/rpc/get-player-inventory/[playerId]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TPlayerInventoryParams>

# function getPlayerInventoryServer( params: TPlayerInventoryParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/inventory/core/getPlayerInventoryServer.ts` 
# TypeScript Types:

type TResult = {
  raw: TPlayerInventory[]
  byKey: TPlayerInventoryRecordBySlotId
  apiPath: string
  atomName: string
}

# function getPlayerInventory(params: TPlayerInventoryParams)
# path: `db/postgresMainDatabase/schemas/inventory/playerInventory.ts` 
# TypeScript Types:

export type TPlayerInventoryParams = {
  playerId: number
}

export type TPlayerInventory = {
  slotId: number
  containerId: number
  inventoryContainerTypeId: number
  inventorySlotTypeId: number
  itemId: number
  name: string
  quantity: number
}

export type TPlayerInventoryRecordBySlotId = Record<string, TPlayerInventory>

Hook for mutate data using SWR
# function path :`methods/hooks/inventory/core/useMutatePlayerInventory.ts` 
# function useMutatePlayerInventory( params: TPlayerInventoryParams)

#### PostgreSQL Database
# "schema": "inventory"
# "method": "get_player_inventory"
You have more information in mcp `game-db`
```