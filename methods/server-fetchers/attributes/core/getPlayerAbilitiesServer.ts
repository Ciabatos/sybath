// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerAbilitiesParams } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities" 
import type { TPlayerAbilitiesRecordByAbilityId,TPlayerAbilities } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import { fetchPlayerAbilitiesService } from "@/methods/services/attributes/fetchPlayerAbilitiesService"

type TResult = {
  raw: TPlayerAbilities[]
  byKey: TPlayerAbilitiesRecordByAbilityId
  apiPath: string
  atomName: string
}

export async function getPlayerAbilitiesServer( params: TPlayerAbilitiesParams, options?: { forceFresh?: boolean },): Promise<TResult> {
  const { record } = await fetchPlayerAbilitiesService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/rpc/get-player-abilities/${params.playerId}`,
    atomName: `playerAbilitiesAtom`,
  }
}

