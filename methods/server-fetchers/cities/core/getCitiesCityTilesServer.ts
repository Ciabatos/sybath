// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getCitiesCityTiles } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import type { TCitiesCityTiles, TCitiesCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getCitiesCityTilesServer(): Promise<{
  raw: TCitiesCityTiles[]
  byKey: TCitiesCityTilesRecordByXY
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getCitiesCityTilesData = await getCitiesCityTiles()

  const data = getCitiesCityTilesData ? (arrayToObjectKey(["x", "y"], getCitiesCityTilesData) as TCitiesCityTilesRecordByXY) : {}

  const result = { raw: getCitiesCityTilesData, byKey: data, apiPath: `/api/cities/city-tiles`, atomName: `cityTilesAtom` }
  
  cachedData = result
  lastUpdated = Date.now()

  return result
}
