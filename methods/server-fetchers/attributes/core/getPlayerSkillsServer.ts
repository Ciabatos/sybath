// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills" 
import type { TPlayerSkillsRecordBySkillId,TPlayerSkills } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import { fetchPlayerSkillsService } from "@/methods/services/attributes/fetchPlayerSkillsService"

type TResult = {
  raw: TPlayerSkills[]
  byKey: TPlayerSkillsRecordBySkillId
  apiPath: string
  atomName: string
}

export async function getPlayerSkillsServer( params: TPlayerSkillsParams, options?: { forceFresh?: boolean },): Promise<TResult> {
  const { record } = await fetchPlayerSkillsService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/rpc/get-player-skills/${params.playerId}`,
    atomName: `playerSkillsAtom`,
  }
}

