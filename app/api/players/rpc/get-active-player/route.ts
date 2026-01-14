// GENERATED CODE - DO NOT EDIT MANUALLY - apiGetMethodFetcher.hbs
// Edited: 2023-10-02T15:13:38.255Z Added fetch by userId

import { auth } from "@/auth"
import { fetchActivePlayerService } from "@/methods/services/players/fetchActivePlayerService"
import { NextRequest, NextResponse } from "next/server"

export async function GET(request: NextRequest): Promise<NextResponse> {
  try {
    const session = await auth()
    const sessionUserId = session?.user?.userId

    if (!sessionUserId || isNaN(sessionUserId)) {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 })
    }

    const clientEtag = request.headers.get("if-none-match") ?? undefined

    const { record, etag, cacheHit, etagMatched } = await fetchActivePlayerService(
      { userId: sessionUserId },
      { clientEtag },
    )

    if (cacheHit || etagMatched) {
      return new NextResponse(null, { status: 304, headers: { ETag: etag } })
    }

    return NextResponse.json(record!.raw, { headers: { ETag: etag } })
  } catch (error) {
    console.error(error)
    return NextResponse.json({ message: "Internal Server Error" }, { status: 500 })
  }
}
