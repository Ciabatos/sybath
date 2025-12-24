// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TAttributesSkills, TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { fetchAttributesSkills } from "@/methods/services/attributes/fetchAttributesSkills"

type TResult = {
  raw: TAttributesSkills[]
  byKey: TAttributesSkillsRecordById
  apiPath: string
  atomName: string
}

export async function getAttributesSkillsServer(): Promise<TResult> {
  const { record } = await fetchAttributesSkills()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/skills`,
    atomName: `skillsAtom`,
  }
}
