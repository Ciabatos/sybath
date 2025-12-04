// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesPlayerStats } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import type { TAttributesPlayerStats, TAttributesPlayerStatsRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"

export async function getAttributesPlayerStatsServer(): Promise<{
  raw: TAttributesPlayerStats[]
  byKey: TAttributesPlayerStatsRecordByPlayerId
  apiPath: string
}> {
  const getAttributesPlayerStatsData = await getAttributesPlayerStats()

  const data = getAttributesPlayerStatsData ? (arrayToObjectKey(["playerId"], getAttributesPlayerStatsData) as TAttributesPlayerStatsRecordByPlayerId) : {}

  return { raw: getAttributesPlayerStatsData, byKey: data, apiPath: `/api/attributes/player-stats` }
}
