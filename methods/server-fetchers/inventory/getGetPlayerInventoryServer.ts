// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getGetPlayerInventory } from "@/db/postgresMainDatabase/schemas/inventory/getPlayerInventory"
import type { TGetPlayerInventory } from "@/db/postgresMainDatabase/schemas/inventory/getPlayerInventory"
import type { TGetPlayerInventoryParams } from "@/db/postgresMainDatabase/schemas/inventory/getPlayerInventory" 
import type { TGetPlayerInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/getPlayerInventory"


export async function getGetPlayerInventoryServer( params: TGetPlayerInventoryParams): Promise<{
  raw: TGetPlayerInventory[]
  byKey: TGetPlayerInventoryRecordBySlotId
  apiPath: string
}> {
  const getGetPlayerInventoryData = await getGetPlayerInventory(params)

  const data = getGetPlayerInventoryData ? (arrayToObjectKey(["slotId"], getGetPlayerInventoryData) as TGetPlayerInventoryRecordBySlotId) : {}

  return { raw: getGetPlayerInventoryData, byKey: data, apiPath: `/api/inventory/rpc/get-player-inventory/${params.playerId}` }
}

