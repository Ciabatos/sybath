// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getBuildingsBuildingsByKey } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { TBuildingsBuildingsParams } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import type {
  TBuildingsBuildings,
  TBuildingsBuildingsRecordByCityTileXCityTileY,
} from "@/db/postgresMainDatabase/schemas/buildings/buildings"

export async function getBuildingsBuildingsByKeyServer(params: TBuildingsBuildingsParams): Promise<{
  raw: TBuildingsBuildings[]
  byKey: TBuildingsBuildingsRecordByCityTileXCityTileY
  apiPath: string
}> {
  const getBuildingsBuildingsByKeyData = await getBuildingsBuildingsByKey(params)

  const data = getBuildingsBuildingsByKeyData
    ? (arrayToObjectKey(
        ["cityTileX", "cityTileY"],
        getBuildingsBuildingsByKeyData,
      ) as TBuildingsBuildingsRecordByCityTileXCityTileY)
    : {}

  return { raw: getBuildingsBuildingsByKeyData, byKey: data, apiPath: `/api/buildings/buildings/${params.cityId}` }
}
