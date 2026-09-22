// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayersOnTileParams } from "@/db/postgresMainDatabase/schemas/world/playersOnTile"
import type {
  TPlayersOnTileRecordByOtherPlayerId,
  TPlayersOnTile,
} from "@/db/postgresMainDatabase/schemas/world/playersOnTile"
import { fetchPlayersOnTileService } from "@/methods/services/world/fetchPlayersOnTileService"

type TResult = {
  raw: TPlayersOnTile[]
  byKey: TPlayersOnTileRecordByOtherPlayerId
  apiPath: string
  atomName: string
}

export async function getPlayersOnTileServer(
  params: TPlayersOnTileParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchPlayersOnTileService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/rpc/get-players-on-tile/${params.mapId}/${params.mapTileX}/${params.mapTileY}/${params.playerId}`,
    atomName: `playersOnTileAtom`,
  }
}
