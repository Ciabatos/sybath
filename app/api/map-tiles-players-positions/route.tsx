/* eslint-disable @typescript-eslint/no-unused-vars */
import { getMapsTilesPlayersPositions } from "@/db/postgresMainDatabase/schemas/map/views/mapTilesPlayerPosition"
import { NextRequest, NextResponse } from "next/server"

type TypeParams = {
  null: string
}

export async function GET(request: NextRequest, { params }: { params: TypeParams }): Promise<NextResponse> {
  //const param1 = (await params).param1

  // const searchQueryParams = request.nextUrl.searchParams
  // const login = searchQueryParams.get("login")

  try {
    const result = await getMapsTilesPlayersPositions()

    return NextResponse.json(result)
  } catch (error) {
    return NextResponse.json({ success: false, error: error })
  }
}
