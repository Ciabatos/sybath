---
name: ai-useFetchOtherPlayerGearInventory-description
description: |
  Hook useFetchOtherPlayerGearInventory description, workflow.

  Use when:
  When using hook useFetchOtherPlayerGearInventory or trying to understand it.
---

# useFetchOtherPlayerGearInventory hook Documentation

# function path :`methods/hooks/inventory/core/useFetchOtherPlayerGearInventory.ts`

# function useFetchOtherPlayerGearInventory( params: TOtherPlayerGearInventoryParams)

# Jotai atom name: const otherPlayerGearInventoryAtom = atom<TOtherPlayerGearInventoryRecordBySlotId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/inventory/rpc/get-other-player-gear-inventory/[playerId]/[otherPlayerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
  otherPlayerId: z.coerce.string(),
}) satisfies z.ZodType<TOtherPlayerGearInventoryParams>

# function getOtherPlayerGearInventoryServer( params: TOtherPlayerGearInventoryParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/inventory/core/getOtherPlayerGearInventoryServer.ts`
# TypeScript Types:

type TResult = {
  raw: TOtherPlayerGearInventory[]
  byKey: TOtherPlayerGearInventoryRecordBySlotId
  apiPath: string
  atomName: string
}

# function getOtherPlayerGearInventory(params: TOtherPlayerGearInventoryParams)
# path: `db/postgresMainDatabase/schemas/inventory/otherPlayerGearInventory.ts`
# TypeScript Types:

export type TOtherPlayerGearInventoryParams = {
  playerId: number
  otherPlayerId: string
}

export type TOtherPlayerGearInventory = {
  slotId: number
  containerId: number
  inventoryContainerTypeId: number
  inventorySlotTypeId: number
  itemId: number
  name: string
  quantity: number
}

export type TOtherPlayerGearInventoryRecordBySlotId = Record<string, TOtherPlayerGearInventory>

Hook for mutate data using SWR
# function path :`methods/hooks/inventory/core/useMutateOtherPlayerGearInventory.ts`
# function useMutateOtherPlayerGearInventory( params: TOtherPlayerGearInventoryParams)

#### PostgreSQL Database
# "schema": "inventory"
# "method": "get_other_player_gear_inventory"
You have more information in mcp `game-db`
```
