// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TAttributesSkills, TAttributesSkillsParams, TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { getAttributesSkillsByKey } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { arrayToObjectKeyId } from "@/methods/functions/converters"

export async function getAttributesSkillsByKeyServer(params: TAttributesSkillsParams): Promise<{
  raw: TAttributesSkills[]
  byKey: TAttributesSkillsRecordById
}> {
  const getAttributesSkillsByKeyData = await getAttributesSkillsByKey(params)

  const data = getAttributesSkillsByKeyData ? (arrayToObjectKeyId("id", getAttributesSkillsByKeyData) as TAttributesSkillsRecordById) : {}

  return { raw: getAttributesSkillsByKeyData, byKey: data }
}
