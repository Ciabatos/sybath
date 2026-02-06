// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TBuildingInventoryParams } from "@/db/postgresMainDatabase/schemas/inventory/buildingInventory"
import type {
  TBuildingInventoryRecordBySlotId,
  TBuildingInventory,
} from "@/db/postgresMainDatabase/schemas/inventory/buildingInventory"
import { fetchBuildingInventoryService } from "@/methods/services/inventory/fetchBuildingInventoryService"

type TResult = {
  raw: TBuildingInventory[]
  byKey: TBuildingInventoryRecordBySlotId
  apiPath: string
  atomName: string
}

export async function getBuildingInventoryServer(
  params: TBuildingInventoryParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchBuildingInventoryService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/inventory/rpc/get-building-inventory/${params.buildingId}`,
    atomName: `buildingInventoryAtom`,
  }
}
