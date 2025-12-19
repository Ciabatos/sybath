// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getCitiesCities } from "@/db/postgresMainDatabase/schemas/cities/cities"
import type { TCitiesCities, TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getCitiesCitiesServer(): Promise<{
  raw: TCitiesCities[]
  byKey: TCitiesCitiesRecordByMapTileXMapTileY
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getCitiesCitiesData = await getCitiesCities()

  const data = getCitiesCitiesData ? (arrayToObjectKey(["mapTileX", "mapTileY"], getCitiesCitiesData) as TCitiesCitiesRecordByMapTileXMapTileY) : {}

  const result = { raw: getCitiesCitiesData, byKey: data, apiPath: `/api/cities/cities`, atomName: `citiesAtom` }
  
  cachedData = result
  lastUpdated = Date.now()

  return result
}
