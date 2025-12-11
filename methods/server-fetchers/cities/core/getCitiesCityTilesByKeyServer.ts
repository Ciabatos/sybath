// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getCitiesCityTilesByKey } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { TCitiesCityTilesParams } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import type { TCitiesCityTiles, TCitiesCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"

export async function getCitiesCityTilesByKeyServer(params: TCitiesCityTilesParams): Promise<{
  raw: TCitiesCityTiles[]
  byKey: TCitiesCityTilesRecordByXY
  apiPath: string
}> {
  const getCitiesCityTilesByKeyData = await getCitiesCityTilesByKey(params)

  const data = getCitiesCityTilesByKeyData
    ? (arrayToObjectKey(["x", "y"], getCitiesCityTilesByKeyData) as TCitiesCityTilesRecordByXY)
    : {}

  return { raw: getCitiesCityTilesByKeyData, byKey: data, apiPath: `/api/cities/city-tiles/${params.cityId}` }
}
