// GENERATED CODE - DO NOT EDIT MANUALLY - apiGetTable.hbs

import { auth } from "@/auth"
import { getWorldMaps } from "@/db/postgresMainDatabase/schemas/world/maps"
import crypto from "crypto"
import { NextRequest, NextResponse } from "next/server"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
let cachedETag: string | null = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function GET(request: NextRequest): Promise<NextResponse> {
  const session = await auth()
  const sessionUserId = session?.user?.userId

  if (!sessionUserId || isNaN(sessionUserId)) {
    return NextResponse.json({ message: "Unauthorized" }, { status: 401 })
  }

  try {
    if (!cachedData || Date.now() - lastUpdated > CACHE_TTL) {
      cachedData = await getWorldMaps()
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