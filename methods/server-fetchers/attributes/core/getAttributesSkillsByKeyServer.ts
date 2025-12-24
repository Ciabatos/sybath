// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TAttributesSkills, TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import type{ TAttributesSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/skills" 
import { fetchAttributesSkillsByKey } from "@/methods/services/attributes/fetchAttributesSkillsByKey"

type TResult = {
  raw: TAttributesSkills[]
  byKey: TAttributesSkillsRecordById
  apiPath: string
  atomName: string
}

export async function getAttributesSkillsByKeyServer( params: TAttributesSkillsParams): Promise<TResult> {
  const { record } = await fetchAttributesSkillsByKey(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/skills/${params.id}`,
    atomName: `skillsAtom`,
  }
}