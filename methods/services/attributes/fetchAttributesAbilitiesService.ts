// GENERATED CODE - DO NOT EDIT MANUALLY - serviceGetTable.hbs

import type {
  TAttributesAbilities,
  TAttributesAbilitiesRecordById,
} from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { getAttributesAbilities } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { createServerCache, makeCacheKey } from "@/methods/functions/util/cache"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import crypto from "crypto"

type TCacheRecord = {
  raw: TAttributesAbilities[]
  byKey: TAttributesAbilitiesRecordById
  etag: string
}

type TFetchResult = {
  record: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

const CACHE_TTL = 3_000
const { getCache, setCache, getEtag } = createServerCache<TCacheRecord>(CACHE_TTL)

export async function fetchAttributesAbilitiesService(options?: {
  clientEtag?: string
  forceFresh?: boolean
}): Promise<TFetchResult> {
  const cacheKey = makeCacheKey("getAttributesAbilities")
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

  if (cached && !options?.forceFresh) {
    return {
      record: cached,
      etag: cachedEtag!,
      cacheHit: true,
      etagMatched: false,
    }
  }

  const raw = await getAttributesAbilities()
  const etag = crypto.createHash("sha1").update(JSON.stringify(raw)).digest("hex")

  const byKey = arrayToObjectKey(["id"], raw) as TAttributesAbilitiesRecordById

  const record: TCacheRecord = {
    raw,
    byKey,
    etag,
  }

  // Rekord mimo to wkładamy do cache'a, bo i tak go właśnie policzyliśmy.
  if (!cached && etag === options?.clientEtag && cachedEtag === options?.clientEtag) {
    setCache({
      cacheKey,
      value: record,
      etag,
    })

    return {
      record,
      etag: etag,
      cacheHit: false,
      etagMatched: true,
    }
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
