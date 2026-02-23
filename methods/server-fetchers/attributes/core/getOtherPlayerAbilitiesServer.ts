// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TOtherPlayerAbilitiesParams } from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerAbilities"
import type {
  TOtherPlayerAbilitiesRecordByAbilityId,
  TOtherPlayerAbilities,
} from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerAbilities"
import { fetchOtherPlayerAbilitiesService } from "@/methods/services/attributes/fetchOtherPlayerAbilitiesService"

type TResult = {
  raw: TOtherPlayerAbilities[]
  byKey: TOtherPlayerAbilitiesRecordByAbilityId
  apiPath: string
  atomName: string
}

export async function getOtherPlayerAbilitiesServer(
  params: TOtherPlayerAbilitiesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchOtherPlayerAbilitiesService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/rpc/get-other-player-abilities/${params.playerId}/${params.otherPlayerMaskId}`,
    atomName: `otherPlayerAbilitiesAtom`,
  }
}
