// GENERATED CODE - DO NOT EDIT MANUALLY - serviceGetMethodFetcher.hbs

import type {
  TOtherPlayerInventory,
  TOtherPlayerInventoryRecordBySlotId,
  TOtherPlayerInventoryParams,
} from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerInventory"
import { getOtherPlayerInventory } from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerInventory"
import { createServerCache, makeCacheKey } from "@/methods/functions/util/cache"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import crypto from "crypto"

type TCacheRecord = {
  raw: TOtherPlayerInventory[]
  byKey: TOtherPlayerInventoryRecordBySlotId
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

export async function fetchOtherPlayerInventoryService(
  params: TOtherPlayerInventoryParams,
  options?: { clientEtag?: string; forceFresh?: boolean },
): Promise<TFetchResult> {
  const cacheKey = makeCacheKey("getOtherPlayerInventory", params)
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

  const raw = await getOtherPlayerInventory(params)
  const etag = crypto.createHash("sha1").update(JSON.stringify(raw)).digest("hex")

  const byKey = arrayToObjectKey(["slotId"], raw) as TOtherPlayerInventoryRecordBySlotId

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
