---
name: ai-useFetchTradeInventory-description
description: |
  Hook useFetchTradeInventory description, workflow.

  Use when:
  When using hook useFetchTradeInventory or trying to understand it.
---

# useFetchTradeInventory hook Documentation

# function path :`methods/hooks/trade/core/useFetchTradeInventory.ts`

# function useFetchTradeInventory( params: TTradeInventoryParams)

# Jotai atom name: const tradeInventoryAtom = atom<TTradeInventoryRecordBySlotId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/trade/rpc/get-trade-inventory/[playerId]/[tradeId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
  tradeId: z.coerce.number(),
}) satisfies z.ZodType<TTradeInventoryParams>

# function getTradeInventoryServer( params: TTradeInventoryParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/trade/core/getTradeInventoryServer.ts`
# TypeScript Types:

type TResult = {
  raw: TTradeInventory[]
  byKey: TTradeInventoryRecordBySlotId
  apiPath: string
  atomName: string
}

# function getTradeInventory(params: TTradeInventoryParams)
# path: `db/postgresMainDatabase/schemas/trade/tradeInventory.ts`
# TypeScript Types:

export type TTradeInventoryParams = {
  playerId: number
  tradeId: number
}


export type TTradeInventory = {
  slotId: number
  containerId: number
  inventoryContainerTypeId: number
  inventorySlotTypeId: number
  itemId: number
  name: string
  quantity: number
  side: number
}

export type TTradeInventoryRecordBySlotId = Record<string, TTradeInventory>

Hook for mutate data using SWR
# function path :`methods/hooks/trade/core/useMutateTradeInventory.ts`
# function useMutateTradeInventory( params: TTradeInventoryParams)

#### PostgreSQL Database
# "schema": "trade"
# "method": "get_trade_inventory"
You have more information in mcp `game-db`
```
