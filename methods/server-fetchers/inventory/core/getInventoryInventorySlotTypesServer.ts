// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TInventoryInventorySlotTypes, TInventoryInventorySlotTypesRecordById } from "@/db/postgresMainDatabase/schemas/inventory/inventorySlotTypes"
import { fetchInventoryInventorySlotTypesService } from "@/methods/services/inventory/fetchInventoryInventorySlotTypesService"

type TResult = {
  raw: TInventoryInventorySlotTypes[]
  byKey: TInventoryInventorySlotTypesRecordById
  apiPath: string
  atomName: string
}

export async function getInventoryInventorySlotTypesServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchInventoryInventorySlotTypesService({ forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/inventory/inventory-slot-types`,
    atomName: `inventorySlotTypesAtom`,
  }
}
