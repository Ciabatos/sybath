/* eslint-disable @typescript-eslint/no-unused-vars */
import { getPlayerVisibleMapData } from "@/db/postgresMainDatabase/schemas/map/functions/playerVisibleMapData"
import { NextRequest, NextResponse } from "next/server"

type TypeParams = {
  playerId: number
}

export async function GET(request: NextRequest, { params }: { params: TypeParams }): Promise<NextResponse> {
  const playerId = (await params).playerId

  // const searchQueryParams = request.nextUrl.searchParams
  // const login = searchQueryParams.get("login")

  try {
    const result = await getPlayerVisibleMapData(playerId)

    return NextResponse.json(result)
  } catch (error) {
    return NextResponse.json({ success: false, error: error })
  }
}
