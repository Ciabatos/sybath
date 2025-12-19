// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getBuildingsBuildingTypes } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import type { TBuildingsBuildingTypes, TBuildingsBuildingTypesRecordById } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getBuildingsBuildingTypesServer(): Promise<{
  raw: TBuildingsBuildingTypes[]
  byKey: TBuildingsBuildingTypesRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getBuildingsBuildingTypesData = await getBuildingsBuildingTypes()

  const data = getBuildingsBuildingTypesData ? (arrayToObjectKey(["id"], getBuildingsBuildingTypesData) as TBuildingsBuildingTypesRecordById) : {}

  const result = { raw: getBuildingsBuildingTypesData, byKey: data, apiPath: `/api/buildings/building-types`, atomName: `buildingTypesAtom` }
  
  cachedData = result
  lastUpdated = Date.now()

  return result
}
