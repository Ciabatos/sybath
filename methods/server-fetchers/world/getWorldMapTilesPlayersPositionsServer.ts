// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TWorldMapTilesPlayersPositions, TWorldMapTilesPlayersPositionsRecordByMapIdMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/world/mapTilesPlayersPositions"
import { getWorldMapTilesPlayersPositions } from "@/db/postgresMainDatabase/schemas/world/mapTilesPlayersPositions"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export async function getWorldMapTilesPlayersPositionsServer(): Promise<{
  raw: TWorldMapTilesPlayersPositions[]
  byKey: TWorldMapTilesPlayersPositionsRecordByMapIdMapTileXMapTileY
  apiPath: string
}> {
  const getWorldMapTilesPlayersPositionsData = await getWorldMapTilesPlayersPositions()

  const data = getWorldMapTilesPlayersPositionsData
    ? (arrayToObjectKey(["mapId", "mapTileX", "mapTileY"], getWorldMapTilesPlayersPositionsData) as TWorldMapTilesPlayersPositionsRecordByMapIdMapTileXMapTileY)
    : {}

  return { raw: getWorldMapTilesPlayersPositionsData, byKey: data, apiPath: `/api/world/map-tiles-players-positions` }
}
