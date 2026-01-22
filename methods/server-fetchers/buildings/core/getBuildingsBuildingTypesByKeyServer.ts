// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TBuildingsBuildingTypes, TBuildingsBuildingTypesRecordById } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import type{ TBuildingsBuildingTypesParams } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes" 
import { fetchBuildingsBuildingTypesByKeyService } from "@/methods/services/buildings/fetchBuildingsBuildingTypesByKeyService"

type TResult = {
  raw: TBuildingsBuildingTypes[]
  byKey: TBuildingsBuildingTypesRecordById
  apiPath: string
  atomName: string
}

export async function getBuildingsBuildingTypesByKeyServer( params: TBuildingsBuildingTypesParams, options?: { forceFresh?: boolean },): Promise<TResult> {
  const { record } = await fetchBuildingsBuildingTypesByKeyService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/buildings/building-types/${params.id}`,
    atomName: `buildingTypesAtom`,
  }
}