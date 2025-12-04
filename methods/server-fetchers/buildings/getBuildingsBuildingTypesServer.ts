// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getBuildingsBuildingTypes } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import type { TBuildingsBuildingTypes, TBuildingsBuildingTypesRecordById } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"

export async function getBuildingsBuildingTypesServer(): Promise<{
  raw: TBuildingsBuildingTypes[]
  byKey: TBuildingsBuildingTypesRecordById
  apiPath: string
}> {
  const getBuildingsBuildingTypesData = await getBuildingsBuildingTypes()

  const data = getBuildingsBuildingTypesData ? (arrayToObjectKey(["id"], getBuildingsBuildingTypesData) as TBuildingsBuildingTypesRecordById) : {}

  return { raw: getBuildingsBuildingTypesData, byKey: data, apiPath: `/api/buildings/building-types` }
}
