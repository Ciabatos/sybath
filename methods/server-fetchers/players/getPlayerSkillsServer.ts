// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerSkills, TPlayerSkillsParams, TPlayerSkillsRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/players/playerSkills"
import { getPlayerSkills } from "@/db/postgresMainDatabase/schemas/players/playerSkills"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"

export async function getPlayerSkillsServer(params: TPlayerSkillsParams): Promise<{
  raw: TPlayerSkills[]
  byKey: TPlayerSkillsRecordByPlayerId
  apiPath: string
}> {
  const getPlayerSkillsData = await getPlayerSkills(params)

  const data = getPlayerSkillsData ? (arrayToObjectKeyId("playerId", getPlayerSkillsData) as TPlayerSkillsRecordByPlayerId) : {}

  return { raw: getPlayerSkillsData, byKey: data, apiPath: `/api/players/rpc/player-skills/${params.playerId}` }
}
