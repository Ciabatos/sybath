// GENERATED CODE - DO NOT EDIT MANUALLY - apiGetTableByKey.hbs

import { auth } from "@/auth"
import { getDistrictsDistrictsByKey, TDistrictsDistrictsParams } from "@/db/postgresMainDatabase/schemas/districts/districts"
import crypto from "crypto"
import { NextRequest, NextResponse } from "next/server"
import z from "zod"

type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  id: z.coerce.number(),
}) satisfies z.ZodType<TDistrictsDistrictsParams>

export async function GET(request: NextRequest, { params }: { params: TApiParams }  ): Promise<NextResponse> {
  
  const session = await auth()
  const sessionPlayerId = session?.user?.playerId
  if (!sessionPlayerId || isNaN(sessionPlayerId)) {
    return NextResponse.json({ success: false })
  }
  
  const paramsFromPromise = await params
  const parsedParams = typeParamsSchema.parse(paramsFromPromise)

  try {
    const result = await getDistrictsDistrictsByKey(parsedParams)
  
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