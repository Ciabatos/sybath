// GENERATED CODE - DO NOT EDIT MANUALLY - serviceGetTableByKey.hbs

import type {
  TAttributesStats,
  TAttributesStatsRecordById,
  TAttributesStatsParams,
} from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { getAttributesStatsByKey } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { createServerCache, makeCacheKey } from "@/methods/functions/util/cache"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import crypto from "crypto"

type TCacheRecord = {
  raw: TAttributesStats[]
  byKey: TAttributesStatsRecordById
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

export async function fetchAttributesStatsByKeyService(
  params: TAttributesStatsParams,
  options?: { clientEtag?: string },
): Promise<TFetchResult> {
  const cacheKey = makeCacheKey("getAttributesStatsByKey", params)
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

  const raw = await getAttributesStatsByKey(params)
  const etag = crypto.createHash("sha1").update(JSON.stringify(raw)).digest("hex")

  if (!cached && etag === options?.clientEtag && cachedEtag === options?.clientEtag) {
    return {
      record: undefined,
      etag: etag,
      cacheHit: false,
      etagMatched: true,
    }
  }

  const byKey = arrayToObjectKey(["id"], raw) as TAttributesStatsRecordById

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
