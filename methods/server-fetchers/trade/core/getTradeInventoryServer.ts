// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TTradeInventoryParams } from "@/db/postgresMainDatabase/schemas/trade/tradeInventory"
import type {
  TTradeInventoryRecordBySlotId,
  TTradeInventory,
} from "@/db/postgresMainDatabase/schemas/trade/tradeInventory"
import { fetchTradeInventoryService } from "@/methods/services/trade/fetchTradeInventoryService"

type TResult = {
  raw: TTradeInventory[]
  byKey: TTradeInventoryRecordBySlotId
  apiPath: string
  atomName: string
}

export async function getTradeInventoryServer(
  params: TTradeInventoryParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchTradeInventoryService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/trade/rpc/get-trade-inventory/${params.playerId}/${params.tradeId}`,
    atomName: `tradeInventoryAtom`,
  }
}
