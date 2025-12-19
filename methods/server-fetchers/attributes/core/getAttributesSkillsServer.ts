// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesSkills } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import type { TAttributesSkills, TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getAttributesSkillsServer(): Promise<{
  raw: TAttributesSkills[]
  byKey: TAttributesSkillsRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getAttributesSkillsData = await getAttributesSkills()

  const data = getAttributesSkillsData ? (arrayToObjectKey(["id"], getAttributesSkillsData) as TAttributesSkillsRecordById) : {}

  const result = { raw: getAttributesSkillsData, byKey: data, apiPath: `/api/attributes/skills`, atomName: `skillsAtom` }
  
  cachedData = result
  lastUpdated = Date.now()

  return result
}
