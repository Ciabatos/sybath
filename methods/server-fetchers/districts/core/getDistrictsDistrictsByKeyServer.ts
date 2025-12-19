// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getDistrictsDistrictsByKey } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TDistrictsDistrictsParams } from "@/db/postgresMainDatabase/schemas/districts/districts" 
import type { TDistrictsDistricts, TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getDistrictsDistrictsByKeyServer( params: TDistrictsDistrictsParams): Promise<{
  raw: TDistrictsDistricts[]
  byKey: TDistrictsDistrictsRecordByMapTileXMapTileY
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getDistrictsDistrictsByKeyData = await getDistrictsDistrictsByKey(params)

  const data = getDistrictsDistrictsByKeyData ? (arrayToObjectKey(["mapTileX", "mapTileY"], getDistrictsDistrictsByKeyData) as TDistrictsDistrictsRecordByMapTileXMapTileY) : {}

  const result = { raw: getDistrictsDistrictsByKeyData, byKey: data, apiPath: `/api/districts/districts/${params.mapId}`, atomName: `districtsAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
