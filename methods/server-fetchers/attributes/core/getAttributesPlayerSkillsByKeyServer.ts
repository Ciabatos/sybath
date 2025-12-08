// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesPlayerSkillsByKey } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import { TAttributesPlayerSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import type { TAttributesPlayerSkills, TAttributesPlayerSkillsRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"

export async function getAttributesPlayerSkillsByKeyServer(params: TAttributesPlayerSkillsParams): Promise<{
  raw: TAttributesPlayerSkills[]
  byKey: TAttributesPlayerSkillsRecordByPlayerId
  apiPath: string
}> {
  const getAttributesPlayerSkillsByKeyData = await getAttributesPlayerSkillsByKey(params)

  const data = getAttributesPlayerSkillsByKeyData ? (arrayToObjectKey(["playerId"], getAttributesPlayerSkillsByKeyData) as TAttributesPlayerSkillsRecordByPlayerId) : {}

  return { raw: getAttributesPlayerSkillsByKeyData, byKey: data, apiPath: `/api/attributes/player-skills/${params.playerId}` }
}
