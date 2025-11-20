// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKeysId } from "@/methods/functions/util/converters"
import { getMapBuildingsByKey } from "@/db/postgresMainDatabase/schemas/map/buildings"
import { TMapBuildingsParams } from "@/db/postgresMainDatabase/schemas/map/buildings" 
import type { TMapBuildings, TMapBuildingsRecordByCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/map/buildings"

export async function getMapBuildingsByKeyServer( params: TMapBuildingsParams): Promise<{
  raw: TMapBuildings[]
  byKey: TMapBuildingsRecordByCityTileXCityTileY
  apiPath: string
}> {
  const getMapBuildingsByKeyData = await getMapBuildingsByKey(params)

  const data = getMapBuildingsByKeyData ? (arrayToObjectKeysId("cityTileX", "cityTileY", getMapBuildingsByKeyData) as TMapBuildingsRecordByCityTileXCityTileY) : {}

  return { raw: getMapBuildingsByKeyData, byKey: data, apiPath: `/api/map/buildings/${params.id}` }
}
