// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getBuildingsBuildingsByKey } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { TBuildingsBuildingsParams } from "@/db/postgresMainDatabase/schemas/buildings/buildings" 
import type { TBuildingsBuildings, TBuildingsBuildingsRecordByCityIdCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/buildings/buildings"

export async function getBuildingsBuildingsByKeyServer( params: TBuildingsBuildingsParams): Promise<{
  raw: TBuildingsBuildings[]
  byKey: TBuildingsBuildingsRecordByCityIdCityTileXCityTileY
  apiPath: string
}> {
  const getBuildingsBuildingsByKeyData = await getBuildingsBuildingsByKey(params)

  const data = getBuildingsBuildingsByKeyData ? (arrayToObjectKey(["cityId", "cityTileX", "cityTileY"], getBuildingsBuildingsByKeyData) as TBuildingsBuildingsRecordByCityIdCityTileXCityTileY) : {}

  return { raw: getBuildingsBuildingsByKeyData, byKey: data, apiPath: `/api/buildings/buildings/${params.id}` }
}
