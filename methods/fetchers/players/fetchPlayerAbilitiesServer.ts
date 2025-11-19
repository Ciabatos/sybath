// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerAbilities, TPlayerAbilitiesParams, TPlayerAbilitiesRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/players/playerAbilities"
import { getPlayerAbilities } from "@/db/postgresMainDatabase/schemas/players/playerAbilities"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"

export async function getPlayerAbilitiesServer(params: TPlayerAbilitiesParams): Promise<{
  raw: TPlayerAbilities[]
  byKey: TPlayerAbilitiesRecordByPlayerId
  apiPath: string
}> {
  const getPlayerAbilitiesData = await getPlayerAbilities(params)

  const data = getPlayerAbilitiesData ? (arrayToObjectKeyId("playerId", getPlayerAbilitiesData) as TPlayerAbilitiesRecordByPlayerId) : {}

  return { raw: getPlayerAbilitiesData, byKey: data, apiPath: `/api/players/rpc/player-abilities/${params.playerId}` }
}
