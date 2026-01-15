// GENERATED CODE - DO NOT EDIT MANUALLY - apiGetMethodFetcher.hbs

import { auth } from "@/auth"
import { TPlayerMovementParams } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"
import { fetchPlayerMovementService } from "@/methods/services/world/fetchPlayerMovementService"
import { NextRequest, NextResponse } from "next/server"
import z from "zod"

type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TPlayerMovementParams>

export async function GET(request: NextRequest, { params }: { params: TApiParams } ): Promise<NextResponse> {
  try {
    const session = await auth()
    const sessionUserId = session?.user?.userId

    if (!sessionUserId || isNaN(sessionUserId)) {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 })
    }

    const paramsFromPromise = await params
    const parsedParams = typeParamsSchema.parse(paramsFromPromise)

    const sessionPlayerId = (await getActivePlayerServer({ userId: sessionUserId })).raw[0].id

    if (sessionPlayerId !== parsedParams.playerId) {
      return NextResponse.json({ message: "Not found" }, { status: 404 })
    }
    
    const clientEtag = request.headers.get("if-none-match") ?? undefined

    const { record, etag, cacheHit, etagMatched } = await fetchPlayerMovementService(parsedParams, { clientEtag })

    if (cacheHit || etagMatched) {
      return new NextResponse(null, { status: 304, headers: { ETag: etag } })
    }

    return NextResponse.json(record!.raw, { headers: { ETag: etag } })
  } catch (error) {
    console.error(error)
    return NextResponse.json({ message: "Internal Server Error" }, { status: 500 })
  }
}