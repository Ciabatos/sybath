// GENERATED CODE - DO NOT EDIT MANUALLY - apiGetTable.hbs

import { auth } from "@/auth"
import { fetchDistrictsDistrictsService } from "@/methods/services/districts/fetchDistrictsDistrictsService"
import { NextRequest, NextResponse } from "next/server"

export async function GET(request: NextRequest): Promise<NextResponse> {
  try {
    const session = await auth()
    const sessionUserId = session?.user?.userId

    if (!sessionUserId || isNaN(sessionUserId)) {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 })
    }

    const clientEtag = request.headers.get("if-none-match") ?? undefined

    const { record, etag, cacheHit, etagMatched } = await fetchDistrictsDistrictsService({ clientEtag })

    if (cacheHit || etagMatched) {
      return new NextResponse(null, { status: 304, headers: { ETag: etag } })
    }

    return NextResponse.json(record!.raw, { headers: { ETag: etag } })
  } catch (error) {
    console.error(error)
    return NextResponse.json({ message: "Internal Server Error" }, { status: 500 })
  }
}