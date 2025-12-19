// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getDistrictsDistrictTypesByKey } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TDistrictsDistrictTypesParams } from "@/db/postgresMainDatabase/schemas/districts/districtTypes" 
import type { TDistrictsDistrictTypes, TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getDistrictsDistrictTypesByKeyServer( params: TDistrictsDistrictTypesParams): Promise<{
  raw: TDistrictsDistrictTypes[]
  byKey: TDistrictsDistrictTypesRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getDistrictsDistrictTypesByKeyData = await getDistrictsDistrictTypesByKey(params)

  const data = getDistrictsDistrictTypesByKeyData ? (arrayToObjectKey(["id"], getDistrictsDistrictTypesByKeyData) as TDistrictsDistrictTypesRecordById) : {}

  const result = { raw: getDistrictsDistrictTypesByKeyData, byKey: data, apiPath: `/api/districts/district-types/${params.id}`, atomName: `districtTypesAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
