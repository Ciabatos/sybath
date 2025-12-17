// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerSkills } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import type { TPlayerSkills } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import type { TPlayerSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import type { TPlayerSkillsRecordBySkillId } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"

export async function getPlayerSkillsServer(params: TPlayerSkillsParams): Promise<{
  raw: TPlayerSkills[]
  byKey: TPlayerSkillsRecordBySkillId
  apiPath: string
  atomName: string
}> {
  const getPlayerSkillsData = await getPlayerSkills(params)

  const data = getPlayerSkillsData
    ? (arrayToObjectKey(["skillId"], getPlayerSkillsData) as TPlayerSkillsRecordBySkillId)
    : {}

  return {
    raw: getPlayerSkillsData,
    byKey: data,
    apiPath: `/api/attributes/rpc/get-player-skills/${params.playerId}`,
    atomName: `playerSkillsAtom`,
  }
}
