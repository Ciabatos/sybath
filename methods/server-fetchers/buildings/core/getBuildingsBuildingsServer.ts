// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TBuildingsBuildings, TBuildingsBuildingsRecordByCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { fetchBuildingsBuildings } from "@/methods/services/buildings/fetchBuildingsBuildings"

type TResult = {
  raw: TBuildingsBuildings[]
  byKey: TBuildingsBuildingsRecordByCityTileXCityTileY
  apiPath: string
  atomName: string
}

export async function getBuildingsBuildingsServer(): Promise<TResult> {
  const { record } = await fetchBuildingsBuildings()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/buildings/buildings`,
    atomName: `buildingsAtom`,
  }
}
