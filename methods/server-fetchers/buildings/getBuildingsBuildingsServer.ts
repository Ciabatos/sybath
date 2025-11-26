// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TBuildingsBuildings, TBuildingsBuildingsRecordByCityIdCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { getBuildingsBuildings } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export async function getBuildingsBuildingsServer(): Promise<{
  raw: TBuildingsBuildings[]
  byKey: TBuildingsBuildingsRecordByCityIdCityTileXCityTileY
  apiPath: string
}> {
  const getBuildingsBuildingsData = await getBuildingsBuildings()

  const data = getBuildingsBuildingsData ? (arrayToObjectKey(["cityId", "cityTileX", "cityTileY"], getBuildingsBuildingsData) as TBuildingsBuildingsRecordByCityIdCityTileXCityTileY) : {}

  return { raw: getBuildingsBuildingsData, byKey: data, apiPath: `/api/buildings/buildings` }
}
