// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerInventoryParams } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory" 
import type { TPlayerInventoryRecordBySlotId,TPlayerInventory } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import { fetchPlayerInventoryService } from "@/methods/services/inventory/fetchPlayerInventoryService"

type TResult = {
  raw: TPlayerInventory[]
  byKey: TPlayerInventoryRecordBySlotId
  apiPath: string
  atomName: string
}

export async function getPlayerInventoryServer( params: TPlayerInventoryParams): Promise<TResult> {
  const { record } = await fetchPlayerInventoryService(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `api/inventory/rpc/get-player-inventory/${params.playerId}`,
    atomName: `playerInventoryAtom`,
  }
}

