// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerInventoryParams } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory" 
import type { TPlayerInventoryRecordBySlotId,TPlayerInventory } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import { fetchPlayerInventory } from "@/methods/services/inventory/fetchPlayerInventory"

type TResult = {
  raw: TPlayerInventory[]
  byKey: TPlayerInventoryRecordBySlotId
  apiPath: string
  atomName: string
}

export async function getPlayerInventoryServer( params: TPlayerInventoryParams): Promise<TResult> {
  const { record } = await fetchPlayerInventory(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `api/inventory/rpc/get-player-inventory/${params.playerId}`,
    atomName: `playerInventoryAtom`,
  }
}

