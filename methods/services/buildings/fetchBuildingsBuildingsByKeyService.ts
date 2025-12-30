// GENERATED CODE - DO NOT EDIT MANUALLY - serviceGetTableByKey.hbs

import type {
  TBuildingsBuildings,
  TBuildingsBuildingsRecordByCityTileXCityTileY,
  TBuildingsBuildingsParams,
} from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { getBuildingsBuildingsByKey } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { createServerCache, makeCacheKey } from "@/methods/functions/util/cache"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import crypto from "crypto"

type TCacheRecord = {
  raw: TBuildingsBuildings[]
  byKey: TBuildingsBuildingsRecordByCityTileXCityTileY
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

const CACHE_TTL = 3_000
const { getCache, setCache, getEtag } = createServerCache<TCacheRecord>(CACHE_TTL)

export async function fetchBuildingsBuildingsByKeyService(
  params: TBuildingsBuildingsParams,
  options?: { clientEtag?: string },
): Promise<TFetchResult> {
  const cacheKey = makeCacheKey("getBuildingsBuildingsByKey", params)
  const cached = getCache(cacheKey)
  const cachedEtag = getEtag(cacheKey)

  if (cached && cachedEtag === options?.clientEtag) {
    return {
      record: cached,
      etag: cachedEtag!,
      cacheHit: true,
      etagMatched: true,
    }
  }

  if (cached) {
    return {
      record: cached,
      etag: cachedEtag!,
      cacheHit: true,
      etagMatched: false,
    }
  }

  const raw = await getBuildingsBuildingsByKey(params)
  const etag = crypto.createHash("sha1").update(JSON.stringify(raw)).digest("hex")

  if (!cached && etag === options?.clientEtag && cachedEtag === options?.clientEtag) {
    return {
      record: undefined,
      etag: etag,
      cacheHit: false,
      etagMatched: true,
    }
  }

  const byKey = arrayToObjectKey(["cityTileX", "cityTileY"], raw) as TBuildingsBuildingsRecordByCityTileXCityTileY

  const record: TCacheRecord = {
    raw,
    byKey,
    etag,
  }

  setCache({
    cacheKey,
    value: record,
    etag,
  })

  return {
    record,
    etag: etag,
    cacheHit: false,
    etagMatched: false,
  }
}
