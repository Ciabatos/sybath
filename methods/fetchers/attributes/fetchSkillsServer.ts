// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKeyId } from "@/methods/functions/converters"
import { getAttributesSkills } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import type { TAttributesSkills, TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"

export async function getAttributesSkillsServer(): Promise<{
  raw: TAttributesSkills[]
  byKey: TAttributesSkillsRecordById
  apiPath: string
}> {
  const getAttributesSkillsData = await getAttributesSkills()

  const data = getAttributesSkillsData ? (arrayToObjectKeyId("id", getAttributesSkillsData) as TAttributesSkillsRecordById) : {}

  return { raw: getAttributesSkillsData, byKey: data, apiPath: `/api/attributes/skills` }
}
