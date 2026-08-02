// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TTradesParams } from "@/db/postgresMainDatabase/schemas/trade/trades"
import type { TTradesRecordByTradeId, TTrades } from "@/db/postgresMainDatabase/schemas/trade/trades"
import { fetchTradesService } from "@/methods/services/trade/fetchTradesService"

type TResult = {
  raw: TTrades[]
  byKey: TTradesRecordByTradeId
  apiPath: string
  atomName: string
}

export async function getTradesServer(params: TTradesParams, options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchTradesService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/trade/rpc/get-trades/${params.playerId}`,
    atomName: `tradesAtom`,
  }
}
