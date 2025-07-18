/* eslint-disable @typescript-eslint/no-unused-vars */
import { auth } from "@/auth"
import { getCityTiles } from "@/db/postgresMainDatabase/schemas/map/cityTiles"
import crypto from "crypto"
import { NextRequest, NextResponse } from "next/server"
import z from "zod"

const typeParamsSchema = z.object({
  id: z.coerce.number(),
})

type TypeParams = z.infer<typeof typeParamsSchema>

export async function GET(request: NextRequest, { params }: { params: TypeParams }): Promise<NextResponse> {
  const paramsFromPromise = await params
  const parsedParamsZod = typeParamsSchema.parse(paramsFromPromise)

  const session = await auth()
  const sessionPlayerId = session?.user?.playerId

  if (!sessionPlayerId || isNaN(sessionPlayerId)) {
    return NextResponse.json({ success: false })
  }

  const cityId = parsedParamsZod.id

  // const searchQueryParams = request.nextUrl.searchParams;
  // const login = searchQueryParams.get("login");

  try {
    const result = await getCityTiles(cityId)
    const etag = crypto.createHash("sha1").update(JSON.stringify(result)).digest("hex")
    const clientEtag = request.headers.get("if-none-match")

    if (clientEtag === etag) {
      return new NextResponse(null, { status: 304, headers: { ETag: etag } })
    }

    return NextResponse.json(result, { headers: { ETag: etag } })
  } catch (error) {
    return NextResponse.json({ success: false, error: error })
  }
}
