// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayersOnTheSameTileParams } from "@/db/postgresMainDatabase/schemas/world/playersOnTheSameTile"
import type {
  TPlayersOnTheSameTileRecordByOtherPlayerId,
  TPlayersOnTheSameTile,
} from "@/db/postgresMainDatabase/schemas/world/playersOnTheSameTile"
import { fetchPlayersOnTheSameTileService } from "@/methods/services/world/fetchPlayersOnTheSameTileService"

type TResult = {
  raw: TPlayersOnTheSameTile[]
  byKey: TPlayersOnTheSameTileRecordByOtherPlayerId
  apiPath: string
  atomName: string
}

export async function getPlayersOnTheSameTileServer(
  params: TPlayersOnTheSameTileParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchPlayersOnTheSameTileService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/rpc/get-players-on-the-same-tile/${params.mapId}/${params.playerId}`,
    atomName: `playersOnTheSameTileAtom`,
  }
}
