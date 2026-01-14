// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type {
  TPlayerMap,
  TPlayerMapParams,
  TPlayerMapRecordByMapId,
} from "@/db/postgresMainDatabase/schemas/world/playerMap"
import { fetchPlayerMapService } from "@/methods/services/world/fetchPlayerMapService"

type TResult = {
  raw: TPlayerMap[]
  byKey: TPlayerMapRecordByMapId
  apiPath: string
  atomName: string
}

export async function getPlayerMapServer(params: TPlayerMapParams): Promise<TResult> {
  const { record } = await fetchPlayerMapService(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/rpc/get-player-map/${params.playerId}`,
    atomName: `playerMapAtom`,
  }
}
