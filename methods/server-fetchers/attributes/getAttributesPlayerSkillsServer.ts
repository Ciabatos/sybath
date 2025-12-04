// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesPlayerSkills } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import type { TAttributesPlayerSkills, TAttributesPlayerSkillsRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"

export async function getAttributesPlayerSkillsServer(): Promise<{
  raw: TAttributesPlayerSkills[]
  byKey: TAttributesPlayerSkillsRecordByPlayerId
  apiPath: string
}> {
  const getAttributesPlayerSkillsData = await getAttributesPlayerSkills()

  const data = getAttributesPlayerSkillsData ? (arrayToObjectKey(["playerId"], getAttributesPlayerSkillsData) as TAttributesPlayerSkillsRecordByPlayerId) : {}

  return { raw: getAttributesPlayerSkillsData, byKey: data, apiPath: `/api/attributes/player-skills` }
}
