// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesSkills } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import type {
  TAttributesSkills,
  TAttributesSkillsRecordById,
} from "@/db/postgresMainDatabase/schemas/attributes/skills"

export async function getAttributesSkillsServer(): Promise<{
  raw: TAttributesSkills[]
  byKey: TAttributesSkillsRecordById
  apiPath: string
}> {
  const getAttributesSkillsData = await getAttributesSkills()

  const data = getAttributesSkillsData
    ? (arrayToObjectKey(["id"], getAttributesSkillsData) as TAttributesSkillsRecordById)
    : {}

  return { raw: getAttributesSkillsData, byKey: data, apiPath: `/api/attributes/skills` }
}
