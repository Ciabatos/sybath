// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getBuildingsBuildings } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import type { TBuildingsBuildings, TBuildingsBuildingsRecordByCityIdCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/buildings/buildings"


export async function getBuildingsBuildingsServer(): Promise<{
  raw: TBuildingsBuildings[]
  byKey: TBuildingsBuildingsRecordByCityIdCityTileXCityTileY
  apiPath: string
}> {
  const getBuildingsBuildingsData = await getBuildingsBuildings()

  const data = getBuildingsBuildingsData ? (arrayToObjectKey(["cityId", "cityTileX", "cityTileY"], getBuildingsBuildingsData) as TBuildingsBuildingsRecordByCityIdCityTileXCityTileY) : {}

  return { raw: getBuildingsBuildingsData, byKey: data, apiPath: `/api/buildings/buildings` }
}
