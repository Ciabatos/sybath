// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesPlayerStatsByKey } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import { TAttributesPlayerStatsParams } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import type {
  TAttributesPlayerStats,
  TAttributesPlayerStatsRecordByPlayerId,
} from "@/db/postgresMainDatabase/schemas/attributes/playerStats"

export async function getAttributesPlayerStatsByKeyServer(params: TAttributesPlayerStatsParams): Promise<{
  raw: TAttributesPlayerStats[]
  byKey: TAttributesPlayerStatsRecordByPlayerId
  apiPath: string
}> {
  const getAttributesPlayerStatsByKeyData = await getAttributesPlayerStatsByKey(params)

  const data = getAttributesPlayerStatsByKeyData
    ? (arrayToObjectKey(["playerId"], getAttributesPlayerStatsByKeyData) as TAttributesPlayerStatsRecordByPlayerId)
    : {}

  return {
    raw: getAttributesPlayerStatsByKeyData,
    byKey: data,
    apiPath: `/api/attributes/player-stats/${params.playerId}`,
  }
}
