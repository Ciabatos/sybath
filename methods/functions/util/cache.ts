import crypto from "crypto"

type CacheEntry<T> = {
  value: T
  lastUpdated: number
}

export function createServerCache<T>(ttl: number) {
  const cache = new Map<string, CacheEntry<T>>()
  const etags = new Map<string, string>()

  function getCache(cacheKey: string): T | null {
    const entry = cache.get(cacheKey)
    if (!entry) return null
    if (Date.now() - entry.lastUpdated > ttl) {
      cache.delete(cacheKey)
      return null
    }
    return entry.value
  }

  function setCache({ cacheKey, value, etag }: { cacheKey: string; value: T; etag: string }) {
    cache.set(cacheKey, {
      value,
      lastUpdated: Date.now(),
    })
    setEtag(cacheKey, etag)
  }

  function setEtag(cacheKey: string, etag: string) {
    etags.delete(cacheKey)
    etags.set(cacheKey, etag)
  }

  function getEtag(cacheKey: string): string | null {
    return etags.get(cacheKey) ?? null
  }

  return { getCache, setCache, getEtag }
}

export function makeCacheKey(source: string, params?: Record<string, unknown>) {
  const raw = !params || Object.keys(params).length === 0 ? source : `${source}:${stableStringify(params)}`

  return crypto.createHash("sha1").update(raw).digest("hex")
}

function stableStringify(obj: Record<string, unknown>) {
  return JSON.stringify(
    Object.keys(obj)
      .sort()
      .reduce(
        (acc, key) => {
          acc[key] = obj[key]
          return acc
        },
        {} as Record<string, unknown>,
      ),
  )
}
