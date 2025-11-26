// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getMapCityTiles } from "@/db/postgresMainDatabase/schemas/map/cityTiles"
import type { TMapCityTiles, TMapCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/map/cityTiles"

export async function getMapCityTilesServer(): Promise<{
  raw: TMapCityTiles[]
  byKey: TMapCityTilesRecordByXY
  apiPath: string
}> {
  const getMapCityTilesData = await getMapCityTiles()

  const data = getMapCityTilesData ? (arrayToObjectKey(["x", "y"], getMapCityTilesData) as TMapCityTilesRecordByXY) : {}

  return { raw: getMapCityTilesData, byKey: data, apiPath: `/api/map/city-tiles` }
}
