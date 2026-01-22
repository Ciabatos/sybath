// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerPositionParams } from "@/db/postgresMainDatabase/schemas/world/playerPosition" 
import type { TPlayerPositionRecordByXY,TPlayerPosition } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { fetchPlayerPositionService } from "@/methods/services/world/fetchPlayerPositionService"

type TResult = {
  raw: TPlayerPosition[]
  byKey: TPlayerPositionRecordByXY
  apiPath: string
  atomName: string
}

export async function getPlayerPositionServer( params: TPlayerPositionParams, options?: { forceFresh?: boolean },): Promise<TResult> {
  const { record } = await fetchPlayerPositionService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/rpc/get-player-position/${params.mapId}/${params.playerId}`,
    atomName: `playerPositionAtom`,
  }
}

