// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TMapMapTiles, TMapMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/map/mapTiles"
import { getMapMapTilesByKey, TMapMapTilesParams } from "@/db/postgresMainDatabase/schemas/map/mapTiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export async function getMapMapTilesByKeyServer(params: TMapMapTilesParams): Promise<{
  raw: TMapMapTiles[]
  byKey: TMapMapTilesRecordByXY
  apiPath: string
}> {
  const getMapMapTilesByKeyData = await getMapMapTilesByKey(params)

  const data = getMapMapTilesByKeyData ? (arrayToObjectKey("x", "y", getMapMapTilesByKeyData) as TMapMapTilesRecordByXY) : {}

  return { raw: getMapMapTilesByKeyData, byKey: data, apiPath: `/api/map/map-tiles/${params.x}/${params.y}` }
}
