---
name: ai-useFetchPlayerGearInventory-description
description: |
  Hook useFetchPlayerGearInventory description, workflow.

  Use when:
  When using hook useFetchPlayerGearInventory or trying to understand it.
---

# useFetchPlayerGearInventory hook Documentation

# function path :`methods/hooks/inventory/core/useFetchPlayerGearInventory.ts`

# function useFetchPlayerGearInventory( params: TPlayerGearInventoryParams)

# Jotai atom name: const playerGearInventoryAtom = atom<TPlayerGearInventoryRecordBySlotId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/inventory/rpc/get-player-gear-inventory/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TPlayerGearInventoryParams>

# function getPlayerGearInventoryServer( params: TPlayerGearInventoryParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/inventory/core/getPlayerGearInventoryServer.ts`
# TypeScript Types:

type TResult = {
  raw: TPlayerGearInventory[]
  byKey: TPlayerGearInventoryRecordBySlotId
  apiPath: string
  atomName: string
}

# function getPlayerGearInventory(params: TPlayerGearInventoryParams)
# path: `db/postgresMainDatabase/schemas/inventory/playerGearInventory.ts`
# TypeScript Types:

export type TPlayerGearInventoryParams = {
  playerId: number
}

export type TPlayerGearInventory = {
  slotId: number
  containerId: number
  inventoryContainerTypeId: number
  inventorySlotTypeId: number
  itemId: number
  name: string
  quantity: number
}

export type TPlayerGearInventoryRecordBySlotId = Record<string, TPlayerGearInventory>

Hook for mutate data using SWR
# function path :`methods/hooks/inventory/core/useMutatePlayerGearInventory.ts`
# function useMutatePlayerGearInventory( params: TPlayerGearInventoryParams)

#### PostgreSQL Database
# "schema": "inventory"
# "method": "get_player_gear_inventory"
You have more information in mcp `game-db`
```
