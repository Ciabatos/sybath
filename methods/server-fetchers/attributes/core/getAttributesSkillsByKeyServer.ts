// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesSkillsByKey } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { TAttributesSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/skills" 
import type { TAttributesSkills, TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getAttributesSkillsByKeyServer( params: TAttributesSkillsParams): Promise<{
  raw: TAttributesSkills[]
  byKey: TAttributesSkillsRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getAttributesSkillsByKeyData = await getAttributesSkillsByKey(params)

  const data = getAttributesSkillsByKeyData ? (arrayToObjectKey(["id"], getAttributesSkillsByKeyData) as TAttributesSkillsRecordById) : {}

  const result = { raw: getAttributesSkillsByKeyData, byKey: data, apiPath: `/api/attributes/skills/${params.id}`, atomName: `skillsAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
