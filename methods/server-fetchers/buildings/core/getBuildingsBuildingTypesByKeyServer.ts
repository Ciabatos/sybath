// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TBuildingsBuildingTypes, TBuildingsBuildingTypesRecordById } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import type{ TBuildingsBuildingTypesParams } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes" 
import { fetchBuildingsBuildingTypesByKey } from "@/methods/services/buildings/fetchBuildingsBuildingTypesByKey"

type TResult = {
  raw: TBuildingsBuildingTypes[]
  byKey: TBuildingsBuildingTypesRecordById
  apiPath: string
  atomName: string
}

export async function getBuildingsBuildingTypesByKeyServer( params: TBuildingsBuildingTypesParams): Promise<TResult> {
  const { record } = await fetchBuildingsBuildingTypesByKey(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/buildings/building-types/${params.id}`,
    atomName: `buildingTypesAtom`,
  }
}