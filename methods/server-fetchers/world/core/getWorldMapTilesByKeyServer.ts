// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TWorldMapTiles, TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { getWorldMapTilesByKey, TWorldMapTilesParams } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { createSimpleServerCache, makeCacheKey } from "@/methods/functions/util/cache"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

type TResult = {
  raw: TWorldMapTiles[]
  byKey: TWorldMapTilesRecordByXY
  apiPath: string
  atomName: string
}

const CACHE_TTL = 3_000
const { getCache, setCache } = createSimpleServerCache<TResult>(CACHE_TTL)

export async function getWorldMapTilesByKeyServer(params: TWorldMapTilesParams): Promise<TResult> {
  const cacheKey = makeCacheKey("getWorldMapTilesByKeyServer", params)

  const cached = getCache(cacheKey)
  if (cached) {
    console.log("Cache hit for getWorldMapTilesByKeyServer", cached)
    return cached
  }

  const getWorldMapTilesByKeyData = await getWorldMapTilesByKey(params)

  const data = getWorldMapTilesByKeyData
    ? (arrayToObjectKey(["x", "y"], getWorldMapTilesByKeyData) as TWorldMapTilesRecordByXY)
    : {}

  const result = {
    raw: getWorldMapTilesByKeyData,
    byKey: data,
    apiPath: `/api/world/map-tiles/${params.mapId}`,
    atomName: `mapTilesAtom`,
  }

  setCache({ cacheKey: cacheKey, value: result })

  return result
}
