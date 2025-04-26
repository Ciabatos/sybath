/* eslint-disable @typescript-eslint/no-unused-vars */
import { auth } from "@/auth"
import { getUsers } from "@/db/postgresMainDatabase/schemas/auth/tables/users"
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

  //const param1 = (await params).param1

  // const searchQueryParams = request.nextUrl.searchParams
  // const login = searchQueryParams.get("login")

  try {
    const result = await getUsers()

    return NextResponse.json(result)
  } catch (error) {
    return NextResponse.json({ success: false, error: error })
  }
}
