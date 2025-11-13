// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKeyId } from "@/methods/functions/converters"
import { getAttributesSkillsByKey } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { TAttributesSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/skills" 
import type { TAttributesSkills, TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"

export async function getAttributesSkillsByKeyServer( params: TAttributesSkillsParams): Promise<{
  raw: TAttributesSkills[]
  byKey: TAttributesSkillsRecordById
}> {
  const getAttributesSkillsByKeyData = await getAttributesSkillsByKey(params)

  const data = getAttributesSkillsByKeyData ? (arrayToObjectKeyId("id", getAttributesSkillsByKeyData) as TAttributesSkillsRecordById) : {}

  return { raw: getAttributesSkillsByKeyData, byKey: data }
}
