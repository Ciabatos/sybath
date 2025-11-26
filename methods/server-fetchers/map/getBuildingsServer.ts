// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getMapBuildings } from "@/db/postgresMainDatabase/schemas/map/buildings"
import type { TMapBuildings, TMapBuildingsRecordByCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/map/buildings"

export async function getMapBuildingsServer(): Promise<{
  raw: TMapBuildings[]
  byKey: TMapBuildingsRecordByCityTileXCityTileY
  apiPath: string
}> {
  const getMapBuildingsData = await getMapBuildings()

  const data = getMapBuildingsData ? (arrayToObjectKey("cityTileX", "cityTileY", getMapBuildingsData) as TMapBuildingsRecordByCityTileXCityTileY) : {}

  return { raw: getMapBuildingsData, byKey: data, apiPath: `/api/map/buildings` }
}
