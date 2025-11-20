// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKeysId } from "@/methods/functions/util/converters"
import { getMapCityTilesByKey } from "@/db/postgresMainDatabase/schemas/map/cityTiles"
import { TMapCityTilesParams } from "@/db/postgresMainDatabase/schemas/map/cityTiles" 
import type { TMapCityTiles, TMapCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/map/cityTiles"

export async function getMapCityTilesByKeyServer( params: TMapCityTilesParams): Promise<{
  raw: TMapCityTiles[]
  byKey: TMapCityTilesRecordByXY
  apiPath: string
}> {
  const getMapCityTilesByKeyData = await getMapCityTilesByKey(params)

  const data = getMapCityTilesByKeyData ? (arrayToObjectKeysId("x", "y", getMapCityTilesByKeyData) as TMapCityTilesRecordByXY) : {}

  return { raw: getMapCityTilesByKeyData, byKey: data, apiPath: `/api/map/city-tiles/${params.cityId}` }
}
