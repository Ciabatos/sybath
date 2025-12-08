// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldMapTilesPlayersPositions } from "@/db/postgresMainDatabase/schemas/world/mapTilesPlayersPositions"
import type { TWorldMapTilesPlayersPositions, TWorldMapTilesPlayersPositionsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/world/mapTilesPlayersPositions"

export async function getWorldMapTilesPlayersPositionsServer(): Promise<{
  raw: TWorldMapTilesPlayersPositions[]
  byKey: TWorldMapTilesPlayersPositionsRecordByMapTileXMapTileY
  apiPath: string
}> {
  const getWorldMapTilesPlayersPositionsData = await getWorldMapTilesPlayersPositions()

  const data = getWorldMapTilesPlayersPositionsData ? (arrayToObjectKey(["mapTileX", "mapTileY"], getWorldMapTilesPlayersPositionsData) as TWorldMapTilesPlayersPositionsRecordByMapTileXMapTileY) : {}

  return { raw: getWorldMapTilesPlayersPositionsData, byKey: data, apiPath: `/api/world/map-tiles-players-positions` }
}
