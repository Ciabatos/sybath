// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TOtherPlayerStatsParams } from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerStats"
import type {
  TOtherPlayerStatsRecordByStatId,
  TOtherPlayerStats,
} from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerStats"
import { fetchOtherPlayerStatsService } from "@/methods/services/attributes/fetchOtherPlayerStatsService"

type TResult = {
  raw: TOtherPlayerStats[]
  byKey: TOtherPlayerStatsRecordByStatId
  apiPath: string
  atomName: string
}

export async function getOtherPlayerStatsServer(
  params: TOtherPlayerStatsParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchOtherPlayerStatsService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/rpc/get-other-player-stats/${params.playerId}/${params.otherPlayerMaskId}`,
    atomName: `otherPlayerStatsAtom`,
  }
}
