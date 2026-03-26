---
name: ai-useFetchDistrictInventory-description
description: |
  Hook useFetchDistrictInventory description, workflow.

  Use when:
  When using hook useFetchDistrictInventory or trying to understand it.
---

# useFetchDistrictInventory hook Documentation

# function path :`methods/hooks/inventory/core/useFetchDistrictInventory.ts`

# function useFetchDistrictInventory( params: TDistrictInventoryParams)

# Jotai atom name: const districtInventoryAtom = atom<TDistrictInventoryRecordBySlotId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/inventory/rpc/get-district-inventory/[districtId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  districtId: z.coerce.number(),
}) satisfies z.ZodType<TDistrictInventoryParams>

# function getDistrictInventoryServer( params: TDistrictInventoryParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/inventory/core/getDistrictInventoryServer.ts`
# TypeScript Types:

type TResult = {
  raw: TDistrictInventory[]
  byKey: TDistrictInventoryRecordBySlotId
  apiPath: string
  atomName: string
}

# function getDistrictInventory(params: TDistrictInventoryParams)
# path: `db/postgresMainDatabase/schemas/inventory/districtInventory.ts`
# TypeScript Types:

export type TDistrictInventoryParams = {
  districtId: number
}

export type TDistrictInventory = {
  slotId: number
  containerId: number
  inventoryContainerTypeId: number
  inventorySlotTypeId: number
  itemId: number
  name: string
  quantity: number
}

export type TDistrictInventoryRecordBySlotId = Record<string, TDistrictInventory>

Hook for mutate data using SWR
# function path :`methods/hooks/inventory/core/useMutateDistrictInventory.ts`
# function useMutateDistrictInventory( params: TDistrictInventoryParams)

#### PostgreSQL Database
# "schema": "inventory"
# "method": "get_district_inventory"
You have more information in mcp `game-db`
```
