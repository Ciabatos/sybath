// GENERATED CODE - DO NOT EDIT MANUALLY - serviceGetMethodFetcher.hbs

import type {
  TOtherSquadPlayersProfiles,
  TOtherSquadPlayersProfilesRecordByOtherPlayerId,
  TOtherSquadPlayersProfilesParams,
} from "@/db/postgresMainDatabase/schemas/squad/otherSquadPlayersProfiles"
import { getOtherSquadPlayersProfiles } from "@/db/postgresMainDatabase/schemas/squad/otherSquadPlayersProfiles"
import { createServerCache, makeCacheKey } from "@/methods/functions/util/cache"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import crypto from "crypto"

type TCacheRecord = {
  raw: TOtherSquadPlayersProfiles[]
  byKey: TOtherSquadPlayersProfilesRecordByOtherPlayerId
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

export async function fetchOtherSquadPlayersProfilesService(
  params: TOtherSquadPlayersProfilesParams,
  options?: { clientEtag?: string; forceFresh?: boolean },
): Promise<TFetchResult> {
  const cacheKey = makeCacheKey("getOtherSquadPlayersProfiles", params)
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

  const raw = await getOtherSquadPlayersProfiles(params)
  const etag = crypto.createHash("sha1").update(JSON.stringify(raw)).digest("hex")

  if (!cached && etag === options?.clientEtag && cachedEtag === options?.clientEtag) {
    return {
      record: undefined,
      etag: etag,
      cacheHit: false,
      etagMatched: true,
    }
  }

  const byKey = arrayToObjectKey(["otherPlayerId"], raw) as TOtherSquadPlayersProfilesRecordByOtherPlayerId

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
