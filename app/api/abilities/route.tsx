/* eslint-disable @typescript-eslint/no-unused-vars */
import { getAbilities } from "@/db/postgresMainDatabase/schemas/players/tables/abilities"
import { NextRequest, NextResponse } from "next/server"

export async function GET(request: NextRequest): Promise<NextResponse> {
  // const searchQueryParams = request.nextUrl.searchParams
  // const login = searchQueryParams.get("login")

  try {
    const result = await getAbilities()

    return NextResponse.json(result)
  } catch (error) {
    return NextResponse.json({ success: false, error: error })
  }
}
