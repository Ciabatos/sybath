// GENERATED CODE - DO NOT EDIT MANUALLY - apiGetTable.hbs

import { auth } from "@/auth"
import { getWorldMapTiles } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import crypto from "crypto"
import { NextRequest, NextResponse } from "next/server"

export async function GET(request: NextRequest): Promise<NextResponse> {
  const session = await auth()
  const sessionUserId = session?.user?.userId
  if (!sessionUserId || isNaN(sessionUserId)) {
    return NextResponse.json({ success: false })
  }

  try {
    const result = await getWorldMapTiles()

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
