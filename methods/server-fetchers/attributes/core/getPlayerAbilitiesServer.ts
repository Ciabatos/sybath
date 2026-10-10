// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerAbilitiesParams } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import type {
  TPlayerAbilitiesRecordByAbilityId,
  TPlayerAbilities,
} from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import { fetchPlayerAbilitiesService } from "@/methods/services/attributes/fetchPlayerAbilitiesService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TPlayerAbilities[]
  byKey: TPlayerAbilitiesRecordByAbilityId
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getPlayerAbilitiesServer(
  params: TPlayerAbilitiesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchPlayerAbilitiesService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/attributes/rpc/get-player-abilities/${params.playerId}`,
    atomName: `playerAbilitiesAtom`,
  }
}
