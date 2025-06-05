/* eslint-disable @typescript-eslint/no-unused-vars */
import { auth } from "@/auth"
import { getMovementActionInProcess, TMovementActionTaskInProcess } from "@/db/postgresMainDatabase/schemas/map/movementActionInProcess"
import crypto from "crypto"
import { NextRequest, NextResponse } from "next/server"

type TypeParams = {
  null: string
}

export type TActionTaskInProcess = {
  movementInProcess: TMovementActionTaskInProcess[]
}

export async function GET(request: NextRequest, { params }: { params: TypeParams }): Promise<NextResponse> {
  const session = await auth()
  const sessionPlayerId = session?.user?.playerId

  if (!sessionPlayerId || isNaN(sessionPlayerId)) {
    return NextResponse.json({ success: false })
  }

  // const searchQueryParams = request.nextUrl.searchParams
  // const login = searchQueryParams.get("login")

  try {
    const [movementInProcess] = await Promise.all([getMovementActionInProcess(sessionPlayerId)])

    const result = {
      movementInProcess: movementInProcess,
    }

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
