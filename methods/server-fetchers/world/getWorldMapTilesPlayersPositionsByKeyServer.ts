// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldMapTilesPlayersPositionsByKey } from "@/db/postgresMainDatabase/schemas/world/mapTilesPlayersPositions"
import { TWorldMapTilesPlayersPositionsParams } from "@/db/postgresMainDatabase/schemas/world/mapTilesPlayersPositions"
import type { TWorldMapTilesPlayersPositions, TWorldMapTilesPlayersPositionsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/world/mapTilesPlayersPositions"

export async function getWorldMapTilesPlayersPositionsByKeyServer(params: TWorldMapTilesPlayersPositionsParams): Promise<{
  raw: TWorldMapTilesPlayersPositions[]
  byKey: TWorldMapTilesPlayersPositionsRecordByMapTileXMapTileY
  apiPath: string
}> {
  const getWorldMapTilesPlayersPositionsByKeyData = await getWorldMapTilesPlayersPositionsByKey(params)

  const data = getWorldMapTilesPlayersPositionsByKeyData
    ? (arrayToObjectKey(["mapTileX", "mapTileY"], getWorldMapTilesPlayersPositionsByKeyData) as TWorldMapTilesPlayersPositionsRecordByMapTileXMapTileY)
    : {}

  return { raw: getWorldMapTilesPlayersPositionsByKeyData, byKey: data, apiPath: `/api/world/map-tiles-players-positions/${params.playerId}` }
}
