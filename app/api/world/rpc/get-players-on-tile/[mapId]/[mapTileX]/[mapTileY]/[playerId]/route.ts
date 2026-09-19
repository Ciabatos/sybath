// GENERATED CODE - DO NOT EDIT MANUALLY - apiGetMethodFetcher.hbs

import { TPlayersOnTileParams } from "@/db/postgresMainDatabase/schemas/world/playersOnTile"
import { auth } from "@/lib/auth"
import { fetchPlayersOnTileService } from "@/methods/services/world/fetchPlayersOnTileService"
import { headers } from "next/headers"
import { NextRequest, NextResponse } from "next/server"
import z from "zod"

type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  mapId: z.coerce.number(),
  mapTileX: z.coerce.number(),
  mapTileY: z.coerce.number(),
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TPlayersOnTileParams>

export async function GET(request: NextRequest, { params }: { params: TApiParams }): Promise<NextResponse> {
  try {
    const session = await auth.api.getSession({ headers: await headers() })
    const sessionUserId = session?.user?.id

    if (!sessionUserId) {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 })
    }

    const paramsFromPromise = await params
    const parsedParams = typeParamsSchema.parse(paramsFromPromise)

    const clientEtag = request.headers.get("if-none-match") ?? undefined
    const forceFresh = request.headers.get("x-force-fresh") ?? undefined

    const { record, etag, cacheHit, etagMatched } = await fetchPlayersOnTileService(parsedParams, {
      ...(forceFresh ? { forceFresh: true } : { clientEtag }),
    })

    if (cacheHit || etagMatched) {
      return new NextResponse(null, { status: 304, headers: { ETag: etag } })
    }

    return NextResponse.json(record!.raw, { headers: { ETag: etag } })
  } catch (error) {
    console.error(error)
    return NextResponse.json({ message: "Internal Server Error" }, { status: 500 })
  }
}
