// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesSkillsByKey } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { TAttributesSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import type { TAttributesSkills, TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"

export async function getAttributesSkillsByKeyServer(params: TAttributesSkillsParams): Promise<{
  raw: TAttributesSkills[]
  byKey: TAttributesSkillsRecordById
  apiPath: string
}> {
  const getAttributesSkillsByKeyData = await getAttributesSkillsByKey(params)

  const data = getAttributesSkillsByKeyData ? (arrayToObjectKey(["id"], getAttributesSkillsByKeyData) as TAttributesSkillsRecordById) : {}

  return { raw: getAttributesSkillsByKeyData, byKey: data, apiPath: `/api/attributes/skills/${params.id}` }
}
