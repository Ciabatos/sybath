/* eslint-disable @typescript-eslint/no-unused-vars */
import { auth } from "@/auth"
import { getInventorySlots } from "@/db/postgresMainDatabase/schemas/players/tables/inventories"
import { NextRequest, NextResponse } from "next/server"

type TypeParams = {
  playerId: number
}

export async function GET(request: NextRequest, { params }: { params: TypeParams }): Promise<NextResponse> {
  const playerId = (await params).playerId
  const session = await auth()
  const dad = session?.user?.playerId

  if (!dad || isNaN(dad)) {
    return NextResponse.json({ success: false })
  }
  // const searchQueryParams = request.nextUrl.searchParams
  // const login = searchQueryParams.get("login")

  try {
    const result = await getInventorySlots(playerId)

    return NextResponse.json(result)
  } catch (error) {
    return NextResponse.json({ success: false, error: error })
  }
}
