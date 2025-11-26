// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TWorldMapTilesPlayersPositions, TWorldMapTilesPlayersPositionsRecordByMapIdMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/world/mapTilesPlayersPositions"
import { getWorldMapTilesPlayersPositionsByKey, TWorldMapTilesPlayersPositionsParams } from "@/db/postgresMainDatabase/schemas/world/mapTilesPlayersPositions"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export async function getWorldMapTilesPlayersPositionsByKeyServer(params: TWorldMapTilesPlayersPositionsParams): Promise<{
  raw: TWorldMapTilesPlayersPositions[]
  byKey: TWorldMapTilesPlayersPositionsRecordByMapIdMapTileXMapTileY
  apiPath: string
}> {
  const getWorldMapTilesPlayersPositionsByKeyData = await getWorldMapTilesPlayersPositionsByKey(params)

  const data = getWorldMapTilesPlayersPositionsByKeyData
    ? (arrayToObjectKey(["mapId", "mapTileX", "mapTileY"], getWorldMapTilesPlayersPositionsByKeyData) as TWorldMapTilesPlayersPositionsRecordByMapIdMapTileXMapTileY)
    : {}

  return { raw: getWorldMapTilesPlayersPositionsByKeyData, byKey: data, apiPath: `/api/world/map-tiles-players-positions/${params.playerId}` }
}
