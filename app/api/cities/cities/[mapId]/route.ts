// GENERATED CODE - DO NOT EDIT MANUALLY - apiGetTableByKey.hbs

import { auth } from "@/auth"
import { TCitiesCitiesParams } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { fetchCitiesCitiesByKeyService } from "@/methods/services/cities/fetchCitiesCitiesByKeyService"
import { NextRequest, NextResponse } from "next/server"
import z from "zod"

type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  mapId: z.coerce.number(),
}) satisfies z.ZodType<TCitiesCitiesParams>

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

    const { record, etag, cacheHit, etagMatched } = await fetchCitiesCitiesByKeyService(parsedParams, { clientEtag })

    if (cacheHit || etagMatched) {
      return new NextResponse(null, { status: 304, headers: { ETag: etag } })
    }

    return NextResponse.json(record!.raw, { headers: { ETag: etag } })
  } catch (error) {
    console.error(error)
    return NextResponse.json({ message: "Internal Server Error" }, { status: 500 })
  }
}