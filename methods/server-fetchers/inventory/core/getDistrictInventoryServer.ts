// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TDistrictInventoryParams } from "@/db/postgresMainDatabase/schemas/inventory/districtInventory"
import type {
  TDistrictInventoryRecordBySlotId,
  TDistrictInventory,
} from "@/db/postgresMainDatabase/schemas/inventory/districtInventory"
import { fetchDistrictInventoryService } from "@/methods/services/inventory/fetchDistrictInventoryService"

type TResult = {
  raw: TDistrictInventory[]
  byKey: TDistrictInventoryRecordBySlotId
  apiPath: string
  atomName: string
}

export async function getDistrictInventoryServer(
  params: TDistrictInventoryParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchDistrictInventoryService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/inventory/rpc/get-district-inventory/${params.districtId}`,
    atomName: `districtInventoryAtom`,
  }
}
