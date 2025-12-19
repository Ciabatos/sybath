// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerInventory } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import type { TPlayerInventory } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import type { TPlayerInventoryParams } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory" 
import type { TPlayerInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getPlayerInventoryServer( params: TPlayerInventoryParams): Promise<{
  raw: TPlayerInventory[]
  byKey: TPlayerInventoryRecordBySlotId
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }
  
  const getPlayerInventoryData = await getPlayerInventory(params)

  const data = getPlayerInventoryData ? (arrayToObjectKey(["slotId"], getPlayerInventoryData) as TPlayerInventoryRecordBySlotId) : {}

  const result = { raw: getPlayerInventoryData, byKey: data, apiPath: `/api/inventory/rpc/get-player-inventory/${params.playerId}`, atomName: `playerInventoryAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}

