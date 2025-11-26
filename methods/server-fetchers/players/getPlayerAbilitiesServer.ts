// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerAbilities } from "@/db/postgresMainDatabase/schemas/players/playerAbilities"
import type { TPlayerAbilities } from "@/db/postgresMainDatabase/schemas/players/playerAbilities"
import type { TPlayerAbilitiesParams } from "@/db/postgresMainDatabase/schemas/players/playerAbilities" 
import type { TPlayerAbilitiesRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/players/playerAbilities"


export async function getPlayerAbilitiesServer( params: TPlayerAbilitiesParams): Promise<{
  raw: TPlayerAbilities[]
  byKey: TPlayerAbilitiesRecordByPlayerId
  apiPath: string
}> {
  const getPlayerAbilitiesData = await getPlayerAbilities(params)

  const data = getPlayerAbilitiesData ? (arrayToObjectKey(["playerId"], getPlayerAbilitiesData) as TPlayerAbilitiesRecordByPlayerId) : {}

  return { raw: getPlayerAbilitiesData, byKey: data, apiPath: `/api/players/rpc/player-abilities/${params.playerId}` }
}

