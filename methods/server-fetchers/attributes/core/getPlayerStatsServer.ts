// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerStatsParams } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import type { TPlayerStatsRecordByStatId, TPlayerStats } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import { fetchPlayerStatsService } from "@/methods/services/attributes/fetchPlayerStatsService"

type TResult = {
  raw: TPlayerStats[]
  byKey: TPlayerStatsRecordByStatId
  apiPath: string
  atomName: string
}

export async function getPlayerStatsServer(
  params: TPlayerStatsParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchPlayerStatsService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/rpc/get-player-stats/${params.playerId}`,
    atomName: `playerStatsAtom`,
  }
}
