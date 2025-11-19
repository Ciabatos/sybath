// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerInventory, TPlayerInventoryParams, TPlayerInventoryRecordByRowCol } from "@/db/postgresMainDatabase/schemas/items/playerInventory"
import { getPlayerInventory } from "@/db/postgresMainDatabase/schemas/items/playerInventory"
import { arrayToObjectKeysId } from "@/methods/functions/util/converters"

export async function getPlayerInventoryServer(params: TPlayerInventoryParams): Promise<{
  raw: TPlayerInventory[]
  byKey: TPlayerInventoryRecordByRowCol
  apiPath: string
}> {
  const getPlayerInventoryData = await getPlayerInventory(params)

  const data = getPlayerInventoryData ? (arrayToObjectKeysId("row", "col", getPlayerInventoryData) as TPlayerInventoryRecordByRowCol) : {}

  return { raw: getPlayerInventoryData, byKey: data, apiPath: `/api/items/rpc/player-inventory/${params.playerId}` }
}
