// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getCitiesCitiesByKey } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TCitiesCitiesParams } from "@/db/postgresMainDatabase/schemas/cities/cities" 
import type { TCitiesCities, TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getCitiesCitiesByKeyServer( params: TCitiesCitiesParams): Promise<{
  raw: TCitiesCities[]
  byKey: TCitiesCitiesRecordByMapTileXMapTileY
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getCitiesCitiesByKeyData = await getCitiesCitiesByKey(params)

  const data = getCitiesCitiesByKeyData ? (arrayToObjectKey(["mapTileX", "mapTileY"], getCitiesCitiesByKeyData) as TCitiesCitiesRecordByMapTileXMapTileY) : {}

  const result = { raw: getCitiesCitiesByKeyData, byKey: data, apiPath: `/api/cities/cities/${params.mapId}`, atomName: `citiesAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
