---
name: ai-useFetchOtherPlayerInventory-description
description: |
  Hook useFetchOtherPlayerInventory description, workflow.

  Use when:
  When using hook useFetchOtherPlayerInventory or trying to understand it.
---

# useFetchOtherPlayerInventory hook Documentation

# function path :`methods/hooks/inventory/core/useFetchOtherPlayerInventory.ts`

# function useFetchOtherPlayerInventory( params: TOtherPlayerInventoryParams)

# Jotai atom name: const otherPlayerInventoryAtom = atom<TOtherPlayerInventoryRecordBySlotId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/inventory/rpc/get-other-player-inventory/[playerId]/[otherPlayerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
  otherPlayerId: z.coerce.string(),
}) satisfies z.ZodType<TOtherPlayerInventoryParams>

# function getOtherPlayerInventoryServer( params: TOtherPlayerInventoryParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/inventory/core/getOtherPlayerInventoryServer.ts`
# TypeScript Types:

type TResult = {
  raw: TOtherPlayerInventory[]
  byKey: TOtherPlayerInventoryRecordBySlotId
  apiPath: string
  atomName: string
}

# function getOtherPlayerInventory(params: TOtherPlayerInventoryParams)
# path: `db/postgresMainDatabase/schemas/inventory/otherPlayerInventory.ts`
# TypeScript Types:

export type TOtherPlayerInventoryParams = {
  playerId: number
  otherPlayerId: string
}

export type TOtherPlayerInventory = {
  slotId: number
  containerId: number
  inventoryContainerTypeId: number
  inventorySlotTypeId: number
  itemId: number
  name: string
  quantity: number
}

export type TOtherPlayerInventoryRecordBySlotId = Record<string, TOtherPlayerInventory>

Hook for mutate data using SWR
# function path :`methods/hooks/inventory/core/useMutateOtherPlayerInventory.ts`
# function useMutateOtherPlayerInventory( params: TOtherPlayerInventoryParams)

#### PostgreSQL Database
# "schema": "inventory"
# "method": "get_other_player_inventory"
You have more information in mcp `game-db`
```
