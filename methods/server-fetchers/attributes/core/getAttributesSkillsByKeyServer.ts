// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TAttributesSkills, TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import type{ TAttributesSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/skills" 
import { fetchAttributesSkillsByKeyService } from "@/methods/services/attributes/fetchAttributesSkillsByKeyService"

type TResult = {
  raw: TAttributesSkills[]
  byKey: TAttributesSkillsRecordById
  apiPath: string
  atomName: string
}

export async function getAttributesSkillsByKeyServer( params: TAttributesSkillsParams): Promise<TResult> {
  const { record } = await fetchAttributesSkillsByKeyService(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/skills/${params.id}`,
    atomName: `skillsAtom`,
  }
}