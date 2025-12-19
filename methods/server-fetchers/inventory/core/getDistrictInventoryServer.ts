// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getDistrictInventory } from "@/db/postgresMainDatabase/schemas/inventory/districtInventory"
import type { TDistrictInventory } from "@/db/postgresMainDatabase/schemas/inventory/districtInventory"
import type { TDistrictInventoryParams } from "@/db/postgresMainDatabase/schemas/inventory/districtInventory" 
import type { TDistrictInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/districtInventory"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getDistrictInventoryServer( params: TDistrictInventoryParams): Promise<{
  raw: TDistrictInventory[]
  byKey: TDistrictInventoryRecordBySlotId
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }
  
  const getDistrictInventoryData = await getDistrictInventory(params)

  const data = getDistrictInventoryData ? (arrayToObjectKey(["slotId"], getDistrictInventoryData) as TDistrictInventoryRecordBySlotId) : {}

  const result = { raw: getDistrictInventoryData, byKey: data, apiPath: `/api/inventory/rpc/get-district-inventory/${params.districtId}`, atomName: `districtInventoryAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}

