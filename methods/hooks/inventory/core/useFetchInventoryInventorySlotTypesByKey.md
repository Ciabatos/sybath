---
name: ai-useFetchInventoryInventorySlotTypesByKey-description
description: |
  Hook useFetchInventoryInventorySlotTypesByKey description, workflow.

  Use when:
  When using hook useFetchInventoryInventorySlotTypesByKey or trying to understand it.
---

# useFetchInventoryInventorySlotTypesByKey hook Documentation

# function path :`methods/hooks/inventory/core/useFetchInventoryInventorySlotTypesByKey.ts`

# function useFetchInventoryInventorySlotTypesByKey( params: TInventoryInventorySlotTypesParams )

# Jotai atom name: const inventorySlotTypesAtom = atom<TInventoryInventorySlotTypesRecordById>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams })
# path: `app/api/inventory/inventory-slot-types/[id]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  id: z.coerce.number(),
}) satisfies z.ZodType<TInventoryInventorySlotTypesParams>

# function fetchInventoryInventorySlotTypesByKeyService(params: TInventoryInventorySlotTypesParams,options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/inventory/fetchInventoryInventorySlotTypesByKeyService.ts`
# TypeScript Types:

type TCacheRecord = {
  raw: TInventoryInventorySlotTypes[]
  byKey: TInventoryInventorySlotTypesRecordById
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function function getInventoryInventorySlotTypesByKey(params: TInventoryInventorySlotTypesParams)
# path: `db/postgresMainDatabase/schemas/inventory/inventorySlotTypes.ts`
# TypeScript Types:

export type TInventoryInventorySlotTypesParams = {
  id: number
}

export type TInventoryInventorySlotTypes = {
  id: number
  name?: string
}

export type TInventoryInventorySlotTypesRecordById = Record<string, TInventoryInventorySlotTypes>

Hook for mutate data using SWR
# function path :`methods/hooks/inventory/core/useMutateInventoryInventorySlotTypesByKey.ts`
# function useMutateInventoryInventorySlotTypes( params: TInventoryInventorySlotTypesParams)

#### PostgreSQL Database
# "schema": "inventory"
# "method": "get_inventory_slot_types_by_key"
You have more information in mcp `game-db`
```
