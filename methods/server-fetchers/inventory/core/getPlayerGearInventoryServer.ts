// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerGearInventoryParams } from "@/db/postgresMainDatabase/schemas/inventory/playerGearInventory" 
import type { TPlayerGearInventoryRecordBySlotId,TPlayerGearInventory } from "@/db/postgresMainDatabase/schemas/inventory/playerGearInventory"
import { fetchPlayerGearInventoryService } from "@/methods/services/inventory/fetchPlayerGearInventoryService"

type TResult = {
  raw: TPlayerGearInventory[]
  byKey: TPlayerGearInventoryRecordBySlotId
  apiPath: string
  atomName: string
}

export async function getPlayerGearInventoryServer( params: TPlayerGearInventoryParams, options?: { forceFresh?: boolean },): Promise<TResult> {
  const { record } = await fetchPlayerGearInventoryService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/inventory/rpc/get-player-gear-inventory/${params.playerId}`,
    atomName: `playerGearInventoryAtom`,
  }
}

