// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TOtherPlayerGearInventoryParams } from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerGearInventory"
import type {
  TOtherPlayerGearInventoryRecordBySlotId,
  TOtherPlayerGearInventory,
} from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerGearInventory"
import { fetchOtherPlayerGearInventoryService } from "@/methods/services/inventory/fetchOtherPlayerGearInventoryService"

type TResult = {
  raw: TOtherPlayerGearInventory[]
  byKey: TOtherPlayerGearInventoryRecordBySlotId
  apiPath: string
  atomName: string
}

export async function getOtherPlayerGearInventoryServer(
  params: TOtherPlayerGearInventoryParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchOtherPlayerGearInventoryService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/inventory/rpc/get-other-player-gear-inventory/${params.playerId}/${params.otherPlayerMaskId}`,
    atomName: `otherPlayerGearInventoryAtom`,
  }
}
