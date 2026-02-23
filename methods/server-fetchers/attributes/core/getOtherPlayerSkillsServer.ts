// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TOtherPlayerSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerSkills"
import type {
  TOtherPlayerSkillsRecordBySkillId,
  TOtherPlayerSkills,
} from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerSkills"
import { fetchOtherPlayerSkillsService } from "@/methods/services/attributes/fetchOtherPlayerSkillsService"

type TResult = {
  raw: TOtherPlayerSkills[]
  byKey: TOtherPlayerSkillsRecordBySkillId
  apiPath: string
  atomName: string
}

export async function getOtherPlayerSkillsServer(
  params: TOtherPlayerSkillsParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchOtherPlayerSkillsService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/rpc/get-other-player-skills/${params.playerId}/${params.otherPlayerMaskId}`,
    atomName: `otherPlayerSkillsAtom`,
  }
}
