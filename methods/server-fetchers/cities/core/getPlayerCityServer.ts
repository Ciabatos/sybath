// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerCityParams } from "@/db/postgresMainDatabase/schemas/cities/playerCity" 
import type { TPlayerCityRecordByCityId,TPlayerCity } from "@/db/postgresMainDatabase/schemas/cities/playerCity"
import { fetchPlayerCityService } from "@/methods/services/cities/fetchPlayerCityService"

type TResult = {
  raw: TPlayerCity[]
  byKey: TPlayerCityRecordByCityId
  apiPath: string
  atomName: string
}

export async function getPlayerCityServer( params: TPlayerCityParams, options?: { forceFresh?: boolean },): Promise<TResult> {
  const { record } = await fetchPlayerCityService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/cities/rpc/get-player-city/${params.playerId}`,
    atomName: `playerCityAtom`,
  }
}

