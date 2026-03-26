// GENERATED CODE - DO NOT EDIT MANUALLY - apiGetMethodFetcher.hbs

import { auth } from "@/auth"
import { TOtherPlayerSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerSkills"
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"
import { fetchOtherPlayerSkillsService } from "@/methods/services/attributes/fetchOtherPlayerSkillsService"
import { NextRequest, NextResponse } from "next/server"
import z from "zod"

type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
  otherPlayerId: z.coerce.string(),
}) satisfies z.ZodType<TOtherPlayerSkillsParams>

export async function GET(request: NextRequest, { params }: { params: TApiParams }): Promise<NextResponse> {
  try {
    const session = await auth()
    const sessionUserId = session?.user?.userId

    if (!sessionUserId || isNaN(sessionUserId)) {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 })
    }

    const paramsFromPromise = await params
    const parsedParams = typeParamsSchema.parse(paramsFromPromise)

    const clientEtag = request.headers.get("if-none-match") ?? undefined
    const forceFresh = request.headers.get("x-force-fresh") ?? undefined

    const { record, etag, cacheHit, etagMatched } = await fetchOtherPlayerSkillsService(parsedParams, {
      ...(forceFresh ? { forceFresh: true } : { clientEtag }),
    })

    if (cacheHit || etagMatched) {
      return new NextResponse(null, { status: 304, headers: { ETag: etag } })
    }

    const sessionPlayerId = (await getActivePlayerServer({ userId: sessionUserId }, { forceFresh: true })).raw[0].id

    if (sessionPlayerId !== parsedParams.playerId) {
      return NextResponse.json({ message: "Not found" }, { status: 404 })
    }

    return NextResponse.json(record!.raw, { headers: { ETag: etag } })
  } catch (error) {
    console.error(error)
    return NextResponse.json({ message: "Internal Server Error" }, { status: 500 })
  }
}
