// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerStats } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import type { TPlayerStats } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import type { TPlayerStatsParams } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import type { TPlayerStatsRecordByStatId } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getPlayerStatsServer(params: TPlayerStatsParams): Promise<{
  raw: TPlayerStats[]
  byKey: TPlayerStatsRecordByStatId
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getPlayerStatsData = await getPlayerStats(params)

  const data = getPlayerStatsData
    ? (arrayToObjectKey(["statId"], getPlayerStatsData) as TPlayerStatsRecordByStatId)
    : {}

  const result = {
    raw: getPlayerStatsData,
    byKey: data,
    apiPath: `/api/attributes/rpc/get-player-stats/${params.playerId}`,
    atomName: `playerStatsAtom`,
  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
