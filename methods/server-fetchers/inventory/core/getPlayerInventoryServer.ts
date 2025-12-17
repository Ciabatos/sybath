// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerInventory } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import type { TPlayerInventory } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import type { TPlayerInventoryParams } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import type { TPlayerInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"

export async function getPlayerInventoryServer(params: TPlayerInventoryParams): Promise<{
  raw: TPlayerInventory[]
  byKey: TPlayerInventoryRecordBySlotId
  apiPath: string
  atomName: string
}> {
  const getPlayerInventoryData = await getPlayerInventory(params)

  const data = getPlayerInventoryData
    ? (arrayToObjectKey(["slotId"], getPlayerInventoryData) as TPlayerInventoryRecordBySlotId)
    : {}

  return {
    raw: getPlayerInventoryData,
    byKey: data,
    apiPath: `/api/inventory/rpc/get-player-inventory/${params.playerId}`,
    atomName: `playerInventoryAtom`,
  }
}
