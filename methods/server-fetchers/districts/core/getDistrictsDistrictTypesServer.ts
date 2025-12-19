// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getDistrictsDistrictTypes } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import type { TDistrictsDistrictTypes, TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getDistrictsDistrictTypesServer(): Promise<{
  raw: TDistrictsDistrictTypes[]
  byKey: TDistrictsDistrictTypesRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getDistrictsDistrictTypesData = await getDistrictsDistrictTypes()

  const data = getDistrictsDistrictTypesData ? (arrayToObjectKey(["id"], getDistrictsDistrictTypesData) as TDistrictsDistrictTypesRecordById) : {}

  const result = { raw: getDistrictsDistrictTypesData, byKey: data, apiPath: `/api/districts/district-types`, atomName: `districtTypesAtom` }
  
  cachedData = result
  lastUpdated = Date.now()

  return result
}
