/* eslint-disable @typescript-eslint/no-unused-vars */
import { auth } from "@/auth"
import { getMapDistricts } from "@/db/postgresMainDatabase/schemas/map/tables/districts"
import { NextRequest, NextResponse } from "next/server"

type TypeParams = {
  null: string
}
export async function GET(request: NextRequest, { params }: { params: TypeParams }): Promise<NextResponse> {
  const session = await auth()
  const sessionPlayerId = session?.user?.playerId

  if (!sessionPlayerId || isNaN(sessionPlayerId)) {
    return NextResponse.json({ success: false })
  }
  // const searchQueryParams = request.nextUrl.searchParams;
  // const login = searchQueryParams.get("login");

  try {
    const result = await getMapDistricts()
    return NextResponse.json(result)
  } catch (error) {
    return NextResponse.json({ success: false, error: error })
  }
}
