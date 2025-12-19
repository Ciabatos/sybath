// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getCitiesCityTilesByKey } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { TCitiesCityTilesParams } from "@/db/postgresMainDatabase/schemas/cities/cityTiles" 
import type { TCitiesCityTiles, TCitiesCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getCitiesCityTilesByKeyServer( params: TCitiesCityTilesParams): Promise<{
  raw: TCitiesCityTiles[]
  byKey: TCitiesCityTilesRecordByXY
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getCitiesCityTilesByKeyData = await getCitiesCityTilesByKey(params)

  const data = getCitiesCityTilesByKeyData ? (arrayToObjectKey(["x", "y"], getCitiesCityTilesByKeyData) as TCitiesCityTilesRecordByXY) : {}

  const result = { raw: getCitiesCityTilesByKeyData, byKey: data, apiPath: `/api/cities/city-tiles/${params.cityId}`, atomName: `cityTilesAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
