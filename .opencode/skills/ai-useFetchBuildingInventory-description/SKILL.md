---
name: ai-useFetchBuildingInventory-description
description: |
  Hook useFetchBuildingInventory description, workflow.

  Use when:
  When using hook useFetchBuildingInventory or trying to understand it.
---



# useFetchBuildingInventory hook Documentation
# function path :`methods/hooks/inventory/core/useFetchBuildingInventory.ts` 
# function useFetchBuildingInventory( params: TBuildingInventoryParams)
# Jotai atom name: const buildingInventoryAtom = atom<TBuildingInventoryRecordBySlotId>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/inventory/rpc/get-building-inventory/[buildingId]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  buildingId: z.coerce.number(),
}) satisfies z.ZodType<TBuildingInventoryParams>

# function getBuildingInventoryServer( params: TBuildingInventoryParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/inventory/core/getBuildingInventoryServer.ts` 
# TypeScript Types:

type TResult = {
  raw: TBuildingInventory[]
  byKey: TBuildingInventoryRecordBySlotId
  apiPath: string
  atomName: string
}

# function getBuildingInventory(params: TBuildingInventoryParams)
# path: `db/postgresMainDatabase/schemas/inventory/buildingInventory.ts` 
# TypeScript Types:

export type TBuildingInventoryParams = {
  buildingId: number
}

export type TBuildingInventory = {
  slotId: number
  containerId: number
  inventoryContainerTypeId: number
  inventorySlotTypeId: number
  itemId: number
  name: string
  quantity: number
}

export type TBuildingInventoryRecordBySlotId = Record<string, TBuildingInventory>

Hook for mutate data using SWR
# function path :`methods/hooks/inventory/core/useMutateBuildingInventory.ts` 
# function useMutateBuildingInventory( params: TBuildingInventoryParams)

#### PostgreSQL Database
# "schema": "inventory"
# "method": "get_building_inventory"
You have more information in mcp `game-db`
```