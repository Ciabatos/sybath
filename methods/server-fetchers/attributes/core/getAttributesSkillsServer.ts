// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type {
  TAttributesSkills,
  TAttributesSkillsRecordById,
} from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { fetchAttributesSkillsService } from "@/methods/services/attributes/fetchAttributesSkillsService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TAttributesSkills[]
  byKey: TAttributesSkillsRecordById
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getAttributesSkillsServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchAttributesSkillsService({ forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/attributes/skills`,
    atomName: `skillsAtom`,
  }
}
