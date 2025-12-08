// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerSkills } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerSkills"
import type { TGetPlayerSkills } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerSkills"
import type { TGetPlayerSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerSkills"
import type { TGetPlayerSkillsRecordBySkillId } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerSkills"

export async function getPlayerSkillsServer(params: TGetPlayerSkillsParams): Promise<{
  raw: TGetPlayerSkills[]
  byKey: TGetPlayerSkillsRecordBySkillId
  apiPath: string
}> {
  const getPlayerSkillsData = await getPlayerSkills(params)

  const data = getPlayerSkillsData ? (arrayToObjectKey(["skillId"], getPlayerSkillsData) as TGetPlayerSkillsRecordBySkillId) : {}

  return { raw: getPlayerSkillsData, byKey: data, apiPath: `/api/attributes/rpc/get-player-skills/${params.playerId}` }
}
