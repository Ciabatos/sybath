// GENERATED CODE - DO NOT EDIT MANUALLY - apiGetTableByKey.hbs

import { auth } from "@/auth"
import { getItemsItemsByKey, TItemsItemsParams } from "@/db/postgresMainDatabase/schemas/items/items"
import crypto from "crypto"
import { NextRequest, NextResponse } from "next/server"
import z from "zod"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
let cachedETag: string | null = null
const CACHE_TTL = 3_000
let lastUpdated = 0

type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  id: z.coerce.number(),
}) satisfies z.ZodType<TItemsItemsParams>

export async function GET(request: NextRequest, { params }: { params: TApiParams }): Promise<NextResponse> {
  const session = await auth()

  const sessionUserId = session?.user?.userId
  if (!sessionUserId || isNaN(sessionUserId)) {
    return NextResponse.json({ message: "Unauthorized" }, { status: 401 })
  }
  
  const paramsFromPromise = await params
  const parsedParams = typeParamsSchema.parse(paramsFromPromise)

  try {
    if (!cachedData || Date.now() - lastUpdated > CACHE_TTL) {
      cachedData = await getItemsItemsByKey(parsedParams)
      cachedETag = crypto.createHash("sha1").update(JSON.stringify(cachedData)).digest("hex")
      lastUpdated = Date.now()
    }
    
    const clientEtag = request.headers.get("if-none-match")

    if (clientEtag === cachedETag) {
      return new NextResponse(null, { status: 304, headers: { ETag: cachedETag! } })
    }

    return NextResponse.json(cachedData, { headers: { ETag: cachedETag! } })
  } catch (error) {
    console.log(error)
    return NextResponse.json({ message: "Internal Server Error" }, { status: 500 })
  }
}
