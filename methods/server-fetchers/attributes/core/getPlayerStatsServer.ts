// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerStats } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import type { TPlayerStats } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import type { TPlayerStatsParams } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import type { TPlayerStatsRecordByStatId } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"

export async function getPlayerStatsServer(params: TPlayerStatsParams): Promise<{
  raw: TPlayerStats[]
  byKey: TPlayerStatsRecordByStatId
  apiPath: string
  atomName: string
}> {
  const getPlayerStatsData = await getPlayerStats(params)

  const data = getPlayerStatsData
    ? (arrayToObjectKey(["statId"], getPlayerStatsData) as TPlayerStatsRecordByStatId)
    : {}

  return {
    raw: getPlayerStatsData,
    byKey: data,
    apiPath: `/api/attributes/rpc/get-player-stats/${params.playerId}`,
    atomName: `playerStatsAtom`,
  }
}
