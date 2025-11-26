// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerSkills } from "@/db/postgresMainDatabase/schemas/players/playerSkills"
import type { TPlayerSkills } from "@/db/postgresMainDatabase/schemas/players/playerSkills"
import type { TPlayerSkillsParams } from "@/db/postgresMainDatabase/schemas/players/playerSkills" 
import type { TPlayerSkillsRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/players/playerSkills"


export async function getPlayerSkillsServer( params: TPlayerSkillsParams): Promise<{
  raw: TPlayerSkills[]
  byKey: TPlayerSkillsRecordByPlayerId
  apiPath: string
}> {
  const getPlayerSkillsData = await getPlayerSkills(params)

  const data = getPlayerSkillsData ? (arrayToObjectKey(["playerId"], getPlayerSkillsData) as TPlayerSkillsRecordByPlayerId) : {}

  return { raw: getPlayerSkillsData, byKey: data, apiPath: `/api/players/rpc/player-skills/${params.playerId}` }
}

