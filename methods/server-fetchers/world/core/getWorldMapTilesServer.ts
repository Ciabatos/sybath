// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldMapTiles } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import type { TWorldMapTiles, TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getWorldMapTilesServer(): Promise<{
  raw: TWorldMapTiles[]
  byKey: TWorldMapTilesRecordByXY
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getWorldMapTilesData = await getWorldMapTiles()

  const data = getWorldMapTilesData ? (arrayToObjectKey(["x", "y"], getWorldMapTilesData) as TWorldMapTilesRecordByXY) : {}

  const result = { raw: getWorldMapTilesData, byKey: data, apiPath: `/api/world/map-tiles`, atomName: `mapTilesAtom` }
  
  cachedData = result
  lastUpdated = Date.now()

  return result
}
