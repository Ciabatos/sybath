// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getBuildingsBuildingsByKey } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { TBuildingsBuildingsParams } from "@/db/postgresMainDatabase/schemas/buildings/buildings" 
import type { TBuildingsBuildings, TBuildingsBuildingsRecordByCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/buildings/buildings"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getBuildingsBuildingsByKeyServer( params: TBuildingsBuildingsParams): Promise<{
  raw: TBuildingsBuildings[]
  byKey: TBuildingsBuildingsRecordByCityTileXCityTileY
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getBuildingsBuildingsByKeyData = await getBuildingsBuildingsByKey(params)

  const data = getBuildingsBuildingsByKeyData ? (arrayToObjectKey(["cityTileX", "cityTileY"], getBuildingsBuildingsByKeyData) as TBuildingsBuildingsRecordByCityTileXCityTileY) : {}

  const result = { raw: getBuildingsBuildingsByKeyData, byKey: data, apiPath: `/api/buildings/buildings/${params.cityId}`, atomName: `buildingsAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
