// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type {
  TInventoryInventorySlotTypes,
  TInventoryInventorySlotTypesRecordById,
} from "@/db/postgresMainDatabase/schemas/inventory/inventorySlotTypes"
import type { TInventoryInventorySlotTypesParams } from "@/db/postgresMainDatabase/schemas/inventory/inventorySlotTypes"
import { fetchInventoryInventorySlotTypesByKeyService } from "@/methods/services/inventory/fetchInventoryInventorySlotTypesByKeyService"

type TResult = {
  raw: TInventoryInventorySlotTypes[]
  byKey: TInventoryInventorySlotTypesRecordById
  apiPath: string
  atomName: string
}

export async function getInventoryInventorySlotTypesByKeyServer(
  params: TInventoryInventorySlotTypesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchInventoryInventorySlotTypesByKeyService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/inventory/inventory-slot-types/${params.id}`,
    atomName: `inventorySlotTypesAtom`,
  }
}
