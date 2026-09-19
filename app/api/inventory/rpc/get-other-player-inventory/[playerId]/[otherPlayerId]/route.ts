// GENERATED CODE - DO NOT EDIT MANUALLY - apiGetMethodFetcher.hbs

import { TOtherPlayerInventoryParams } from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerInventory"
import { auth } from "@/lib/auth"
import { fetchOtherPlayerInventoryService } from "@/methods/services/inventory/fetchOtherPlayerInventoryService"
import { headers } from "next/headers"
import { NextRequest, NextResponse } from "next/server"
import z from "zod"

type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
  otherPlayerId: z.coerce.string(),
}) satisfies z.ZodType<TOtherPlayerInventoryParams>

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

    const { record, etag, cacheHit, etagMatched } = await fetchOtherPlayerInventoryService(parsedParams, {
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
