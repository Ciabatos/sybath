/* eslint-disable @typescript-eslint/no-unused-vars */
import { getMapsTilesPlayerPosition } from "@/db/postgresMainDatabase/schemas/map/views/mapTilesPlayerPosition"
import { NextRequest, NextResponse } from "next/server"

type TypeParams = {
  userId: number
}

export async function GET(request: NextRequest, { params }: { params: TypeParams }): Promise<NextResponse> {
  const userId = (await params).userId

  // const searchQueryParams = request.nextUrl.searchParams
  // const login = searchQueryParams.get("login")

  try {
    const result = await getMapsTilesPlayerPosition(userId)

    return NextResponse.json(result)
  } catch (error) {
    return NextResponse.json({ success: false, error: error })
  }
}
