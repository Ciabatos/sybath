// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type {
  TAttributesSkills,
  TAttributesSkillsRecordById,
} from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { fetchAttributesSkillsService } from "@/methods/services/attributes/fetchAttributesSkillsService"

type TResult = {
  raw: TAttributesSkills[]
  byKey: TAttributesSkillsRecordById
  apiPath: string
  atomName: string
}

export async function getAttributesSkillsServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchAttributesSkillsService({ forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/skills`,
    atomName: `skillsAtom`,
  }
}
