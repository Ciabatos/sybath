// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerGearInventoryParams } from "@/db/postgresMainDatabase/schemas/inventory/playerGearInventory"
import type {
  TPlayerGearInventoryRecordBySlotId,
  TPlayerGearInventory,
} from "@/db/postgresMainDatabase/schemas/inventory/playerGearInventory"
import { fetchPlayerGearInventoryService } from "@/methods/services/inventory/fetchPlayerGearInventoryService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TPlayerGearInventory[]
  byKey: TPlayerGearInventoryRecordBySlotId
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getPlayerGearInventoryServer(
  params: TPlayerGearInventoryParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchPlayerGearInventoryService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/inventory/rpc/get-player-gear-inventory/${params.playerId}`,
    atomName: `playerGearInventoryAtom`,
  }
}
