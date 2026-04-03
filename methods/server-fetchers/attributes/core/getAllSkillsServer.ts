// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TAllSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/allSkills"
import type { TAllSkillsRecordById, TAllSkills } from "@/db/postgresMainDatabase/schemas/attributes/allSkills"
import { fetchAllSkillsService } from "@/methods/services/attributes/fetchAllSkillsService"

type TResult = {
  raw: TAllSkills[]
  byKey: TAllSkillsRecordById
  apiPath: string
  atomName: string
}

export async function getAllSkillsServer(
  params: TAllSkillsParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchAllSkillsService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/rpc/get-all-skills/${params.playerId}`,
    atomName: `allSkillsAtom`,
  }
}
