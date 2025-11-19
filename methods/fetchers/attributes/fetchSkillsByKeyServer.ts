// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TAttributesSkills, TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { getAttributesSkillsByKey, TAttributesSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"

export async function getAttributesSkillsByKeyServer(params: TAttributesSkillsParams): Promise<{
  raw: TAttributesSkills[]
  byKey: TAttributesSkillsRecordById
  apiPath: string
}> {
  const getAttributesSkillsByKeyData = await getAttributesSkillsByKey(params)

  const data = getAttributesSkillsByKeyData ? (arrayToObjectKeyId("id", getAttributesSkillsByKeyData) as TAttributesSkillsRecordById) : {}

  return { raw: getAttributesSkillsByKeyData, byKey: data, apiPath: `/api/attributes/skills/${params.id}` }
}
