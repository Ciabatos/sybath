// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerStats } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerStats"
import type { TGetPlayerStats } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerStats"
import type { TGetPlayerStatsParams } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerStats"
import type { TGetPlayerStatsRecordByStatId } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerStats"

export async function getPlayerStatsServer(params: TGetPlayerStatsParams): Promise<{
  raw: TGetPlayerStats[]
  byKey: TGetPlayerStatsRecordByStatId
  apiPath: string
}> {
  const getPlayerStatsData = await getPlayerStats(params)

  const data = getPlayerStatsData
    ? (arrayToObjectKey(["statId"], getPlayerStatsData) as TGetPlayerStatsRecordByStatId)
    : {}

  return { raw: getPlayerStatsData, byKey: data, apiPath: `/api/attributes/rpc/get-player-stats/${params.playerId}` }
}
