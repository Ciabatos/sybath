// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TAttributesSkills, TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { getAttributesSkills } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"

export async function getAttributesSkillsServer(): Promise<{
  raw: TAttributesSkills[]
  byKey: TAttributesSkillsRecordById
  apiPath: string
}> {
  const getAttributesSkillsData = await getAttributesSkills()

  const data = getAttributesSkillsData ? (arrayToObjectKeyId("id", getAttributesSkillsData) as TAttributesSkillsRecordById) : {}

  return { raw: getAttributesSkillsData, byKey: data, apiPath: `/api/attributes/skills` }
}
