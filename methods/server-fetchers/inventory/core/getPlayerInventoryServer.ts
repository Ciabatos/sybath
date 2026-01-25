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

export async function getPlayerInventoryServer( params: TPlayerInventoryParams, options?: { forceFresh?: boolean },): Promise<TResult> {
  const { record } = await fetchPlayerInventoryService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/inventory/rpc/get-player-inventory/${params.playerId}`,
    atomName: `playerInventoryAtom`,
  }
}

