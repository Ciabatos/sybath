// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getBuildingInventory } from "@/db/postgresMainDatabase/schemas/inventory/buildingInventory"
import type { TBuildingInventory } from "@/db/postgresMainDatabase/schemas/inventory/buildingInventory"
import type { TBuildingInventoryParams } from "@/db/postgresMainDatabase/schemas/inventory/buildingInventory"
import type { TBuildingInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/buildingInventory"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getBuildingInventoryServer(params: TBuildingInventoryParams): Promise<{
  raw: TBuildingInventory[]
  byKey: TBuildingInventoryRecordBySlotId
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getBuildingInventoryData = await getBuildingInventory(params)

  const data = getBuildingInventoryData
    ? (arrayToObjectKey(["slotId"], getBuildingInventoryData) as TBuildingInventoryRecordBySlotId)
    : {}

  const result = {
    raw: getBuildingInventoryData,
    byKey: data,
    apiPath: `/api/inventory/rpc/get-building-inventory/${params.buildingId}`,
    atomName: `buildingInventoryAtom`,
  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
