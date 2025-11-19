// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerVisibleMapData, TPlayerVisibleMapDataParams, TPlayerVisibleMapDataRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/playerVisibleMapData"
import { getPlayerVisibleMapData } from "@/db/postgresMainDatabase/schemas/map/playerVisibleMapData"
import { arrayToObjectKeysId } from "@/methods/functions/util/converters"

export async function getPlayerVisibleMapDataServer(params: TPlayerVisibleMapDataParams): Promise<{
  raw: TPlayerVisibleMapData[]
  byKey: TPlayerVisibleMapDataRecordByMapTileXMapTileY
  apiPath: string
}> {
  const getPlayerVisibleMapDataData = await getPlayerVisibleMapData(params)

  const data = getPlayerVisibleMapDataData ? (arrayToObjectKeysId("mapTileX", "mapTileY", getPlayerVisibleMapDataData) as TPlayerVisibleMapDataRecordByMapTileXMapTileY) : {}

  return { raw: getPlayerVisibleMapDataData, byKey: data, apiPath: `/api/map/rpc/player-visible-map-data/${params.playerId}` }
}
