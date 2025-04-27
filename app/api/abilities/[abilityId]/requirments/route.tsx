/* eslint-disable @typescript-eslint/no-unused-vars */
import { auth } from "@/auth"
import { getAbilityRequirements } from "@/db/postgresMainDatabase/schemas/players/tables/abilityRequirements"
import { NextRequest, NextResponse } from "next/server"

type TypeParams = {
  abilityId: number
}

export async function GET(request: NextRequest, { params }: { params: TypeParams }): Promise<NextResponse> {
  const session = await auth()
  const sessionPlayerId = session?.user?.playerId

  if (!sessionPlayerId || isNaN(sessionPlayerId)) {
    return NextResponse.json({ success: false })
  }

  const abilityId = (await params).abilityId
  // const searchQueryParams = request.nextUrl.searchParams
  // const login = searchQueryParams.get("login")

  try {
    const result = await getAbilityRequirements(abilityId)

    return NextResponse.json(result)
  } catch (error) {
    return NextResponse.json({ success: false, error: error })
  }
}
