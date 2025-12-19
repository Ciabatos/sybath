// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getBuildingsBuildingTypesByKey } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { TBuildingsBuildingTypesParams } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes" 
import type { TBuildingsBuildingTypes, TBuildingsBuildingTypesRecordById } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getBuildingsBuildingTypesByKeyServer( params: TBuildingsBuildingTypesParams): Promise<{
  raw: TBuildingsBuildingTypes[]
  byKey: TBuildingsBuildingTypesRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getBuildingsBuildingTypesByKeyData = await getBuildingsBuildingTypesByKey(params)

  const data = getBuildingsBuildingTypesByKeyData ? (arrayToObjectKey(["id"], getBuildingsBuildingTypesByKeyData) as TBuildingsBuildingTypesRecordById) : {}

  const result = { raw: getBuildingsBuildingTypesByKeyData, byKey: data, apiPath: `/api/buildings/building-types/${params.id}`, atomName: `buildingTypesAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
