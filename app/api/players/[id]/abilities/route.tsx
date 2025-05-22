/* eslint-disable @typescript-eslint/no-unused-vars */
import { auth } from "@/auth"
import { getPlayerAbilities } from "@/db/postgresMainDatabase/schemas/players/tables/playerAbilities"
import { NextRequest, NextResponse } from "next/server"

type TypeParams = {
  id: number
}

export async function GET(request: NextRequest, { params }: { params: TypeParams }): Promise<NextResponse> {
  const session = await auth()
  const sessionPlayerId = session?.user?.playerId

  if (!sessionPlayerId || isNaN(sessionPlayerId)) {
    return NextResponse.json({ success: false })
  }

  const playerId = (await params).id

  // const searchQueryParams = request.nextUrl.searchParams
  // const login = searchQueryParams.get("login")

  try {
    const result = await getPlayerAbilities(playerId)

    return NextResponse.json(result)
  } catch (error) {
    return NextResponse.json({ success: false, error: error })
  }
}
