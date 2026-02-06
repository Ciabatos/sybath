// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type {
  TBuildingsBuildings,
  TBuildingsBuildingsRecordByCityTileXCityTileY,
} from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { fetchBuildingsBuildingsService } from "@/methods/services/buildings/fetchBuildingsBuildingsService"

type TResult = {
  raw: TBuildingsBuildings[]
  byKey: TBuildingsBuildingsRecordByCityTileXCityTileY
  apiPath: string
  atomName: string
}

export async function getBuildingsBuildingsServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchBuildingsBuildingsService({ forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/buildings/buildings`,
    atomName: `buildingsAtom`,
  }
}
