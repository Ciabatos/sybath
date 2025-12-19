// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldMapTilesByKey } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TWorldMapTilesParams } from "@/db/postgresMainDatabase/schemas/world/mapTiles" 
import type { TWorldMapTiles, TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getWorldMapTilesByKeyServer( params: TWorldMapTilesParams): Promise<{
  raw: TWorldMapTiles[]
  byKey: TWorldMapTilesRecordByXY
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getWorldMapTilesByKeyData = await getWorldMapTilesByKey(params)

  const data = getWorldMapTilesByKeyData ? (arrayToObjectKey(["x", "y"], getWorldMapTilesByKeyData) as TWorldMapTilesRecordByXY) : {}

  const result = { raw: getWorldMapTilesByKeyData, byKey: data, apiPath: `/api/world/map-tiles/${params.mapId}`, atomName: `mapTilesAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
