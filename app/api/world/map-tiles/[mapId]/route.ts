// GENERATED CODE - DO NOT EDIT MANUALLY - apiGetTableByKey.hbs

import { auth } from "@/auth"
import {
  getWorldMapTilesByKey,
  TWorldMapTiles,
  TWorldMapTilesParams,
} from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { createSimpleServerCache, makeCacheKey } from "@/methods/functions/util/cache"
import crypto from "crypto"
import { NextRequest, NextResponse } from "next/server"
import z from "zod"

const CACHE_TTL = 3_000
const { getCache, setCache, getEtag } = createSimpleServerCache<TWorldMapTiles[]>(CACHE_TTL)

type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  mapId: z.coerce.number(),
}) satisfies z.ZodType<TWorldMapTilesParams>

export async function GET(request: NextRequest, { params }: { params: TApiParams }): Promise<NextResponse> {
  const session = await auth()

  const sessionUserId = session?.user?.userId
  if (!sessionUserId || isNaN(sessionUserId)) {
    return NextResponse.json({ message: "Unauthorized" }, { status: 401 })
  }

  const paramsFromPromise = await params
  const parsedParams = typeParamsSchema.parse(paramsFromPromise)

  const cacheKey = makeCacheKey("getWorldMapTilesByKey", parsedParams)
  const cachedValue = getCache(cacheKey)
  const cachedEtag = getEtag(cacheKey)
  const clientEtag = request.headers.get("if-none-match")

  try {
    if (cachedValue && cachedEtag) {
      if (clientEtag === cachedEtag) {
        return new NextResponse(null, { status: 304, headers: { ETag: cachedEtag } })
      }
      return NextResponse.json(cachedValue, { headers: { ETag: cachedEtag } })
    }

    const data = await getWorldMapTilesByKey(parsedParams)
    const etag = crypto.createHash("sha1").update(JSON.stringify(data)).digest("hex")

    if (clientEtag === etag && cachedEtag === etag) {
      return new NextResponse(null, { status: 304, headers: { ETag: etag } })
    }

    if (clientEtag === etag && cachedEtag != etag) {
      setCache({ cacheKey: cacheKey, value: data, etag: etag })
      return new NextResponse(null, { status: 304, headers: { ETag: etag } })
    }

    setCache({ cacheKey: cacheKey, value: data, etag: etag })
    return NextResponse.json(data, { headers: { ETag: etag } })
  } catch (error) {
    console.log(error)
    return NextResponse.json({ message: "Internal Server Error" }, { status: 500 })
  }
}
