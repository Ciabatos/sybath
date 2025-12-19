// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getBuildingsBuildings } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import type { TBuildingsBuildings, TBuildingsBuildingsRecordByCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/buildings/buildings"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getBuildingsBuildingsServer(): Promise<{
  raw: TBuildingsBuildings[]
  byKey: TBuildingsBuildingsRecordByCityTileXCityTileY
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getBuildingsBuildingsData = await getBuildingsBuildings()

  const data = getBuildingsBuildingsData ? (arrayToObjectKey(["cityTileX", "cityTileY"], getBuildingsBuildingsData) as TBuildingsBuildingsRecordByCityTileXCityTileY) : {}

  const result = { raw: getBuildingsBuildingsData, byKey: data, apiPath: `/api/buildings/buildings`, atomName: `buildingsAtom` }
  
  cachedData = result
  lastUpdated = Date.now()

  return result
}
