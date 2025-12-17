// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getBuildingsBuildingTypesByKey } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { TBuildingsBuildingTypesParams } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import type {
  TBuildingsBuildingTypes,
  TBuildingsBuildingTypesRecordById,
} from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"

export async function getBuildingsBuildingTypesByKeyServer(params: TBuildingsBuildingTypesParams): Promise<{
  raw: TBuildingsBuildingTypes[]
  byKey: TBuildingsBuildingTypesRecordById
  apiPath: string
  atomName: string
}> {
  const getBuildingsBuildingTypesByKeyData = await getBuildingsBuildingTypesByKey(params)

  const data = getBuildingsBuildingTypesByKeyData
    ? (arrayToObjectKey(["id"], getBuildingsBuildingTypesByKeyData) as TBuildingsBuildingTypesRecordById)
    : {}

  return {
    raw: getBuildingsBuildingTypesByKeyData,
    byKey: data,
    apiPath: `/api/buildings/building-types/${params.id}`,
    atomName: `buildingTypesAtom`,
  }
}
