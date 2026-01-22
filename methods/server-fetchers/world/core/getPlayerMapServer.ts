// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerMapParams } from "@/db/postgresMainDatabase/schemas/world/playerMap" 
import type { TPlayerMapRecordByMapId,TPlayerMap } from "@/db/postgresMainDatabase/schemas/world/playerMap"
import { fetchPlayerMapService } from "@/methods/services/world/fetchPlayerMapService"

type TResult = {
  raw: TPlayerMap[]
  byKey: TPlayerMapRecordByMapId
  apiPath: string
  atomName: string
}

export async function getPlayerMapServer( params: TPlayerMapParams, options?: { forceFresh?: boolean },): Promise<TResult> {
  const { record } = await fetchPlayerMapService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/rpc/get-player-map/${params.playerId}`,
    atomName: `playerMapAtom`,
  }
}

