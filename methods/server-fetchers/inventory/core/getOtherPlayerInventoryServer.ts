// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TOtherPlayerInventoryParams } from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerInventory"
import type {
  TOtherPlayerInventoryRecordBySlotId,
  TOtherPlayerInventory,
} from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerInventory"
import { fetchOtherPlayerInventoryService } from "@/methods/services/inventory/fetchOtherPlayerInventoryService"

type TResult = {
  raw: TOtherPlayerInventory[]
  byKey: TOtherPlayerInventoryRecordBySlotId
  apiPath: string
  atomName: string
}

export async function getOtherPlayerInventoryServer(
  params: TOtherPlayerInventoryParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchOtherPlayerInventoryService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/inventory/rpc/get-other-player-inventory/${params.playerId}/${params.otherPlayerMaskId}`,
    atomName: `otherPlayerInventoryAtom`,
  }
}
