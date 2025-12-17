// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getBuildingsBuildings } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import type {
  TBuildingsBuildings,
  TBuildingsBuildingsRecordByCityTileXCityTileY,
} from "@/db/postgresMainDatabase/schemas/buildings/buildings"

export async function getBuildingsBuildingsServer(): Promise<{
  raw: TBuildingsBuildings[]
  byKey: TBuildingsBuildingsRecordByCityTileXCityTileY
  apiPath: string
  atomName: string
}> {
  const getBuildingsBuildingsData = await getBuildingsBuildings()

  const data = getBuildingsBuildingsData
    ? (arrayToObjectKey(
        ["cityTileX", "cityTileY"],
        getBuildingsBuildingsData,
      ) as TBuildingsBuildingsRecordByCityTileXCityTileY)
    : {}

  return { raw: getBuildingsBuildingsData, byKey: data, apiPath: `/api/buildings/buildings`, atomName: `buildingsAtom` }
}
