// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerInventoryParams } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import type {
  TPlayerInventoryRecordBySlotId,
  TPlayerInventory,
} from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import { fetchPlayerInventoryService } from "@/methods/services/inventory/fetchPlayerInventoryService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TPlayerInventory[]
  byKey: TPlayerInventoryRecordBySlotId
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getPlayerInventoryServer(
  params: TPlayerInventoryParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchPlayerInventoryService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/inventory/rpc/get-player-inventory/${params.playerId}`,
    atomName: `playerInventoryAtom`,
  }
}
