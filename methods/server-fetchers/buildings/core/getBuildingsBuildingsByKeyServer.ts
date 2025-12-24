// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TBuildingsBuildings, TBuildingsBuildingsRecordByCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import type{ TBuildingsBuildingsParams } from "@/db/postgresMainDatabase/schemas/buildings/buildings" 
import { fetchBuildingsBuildingsByKey } from "@/methods/services/buildings/fetchBuildingsBuildingsByKey"

type TResult = {
  raw: TBuildingsBuildings[]
  byKey: TBuildingsBuildingsRecordByCityTileXCityTileY
  apiPath: string
  atomName: string
}

export async function getBuildingsBuildingsByKeyServer( params: TBuildingsBuildingsParams): Promise<TResult> {
  const { record } = await fetchBuildingsBuildingsByKey(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/buildings/buildings/${params.cityId}`,
    atomName: `buildingsAtom`,
  }
}