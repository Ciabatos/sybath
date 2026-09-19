// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoTradeOpenParams, doTradeOpen } from "@/db/postgresMainDatabase/schemas/trade/doTradeOpen"

//MANUAL CODE - START

export type TDoTradeOpenServiceParams = {
  sessionUserId: string
  playerId: number
  invitedPlayerId: string
}

//MANUAL CODE - END

export async function doTradeOpenService(params: TDoTradeOpenServiceParams) {
  try {
    const sessionPlayerId = params.sessionUserId
    const playerId = params.playerId

    //MANUAL CODE - START

    const invitedPlayerId = params.invitedPlayerId

    //MANUAL CODE - END

    const data: TDoTradeOpenParams = {
      playerId: playerId,
      invitedPlayerId: invitedPlayerId,
    }

    const result = await doTradeOpen(data)
    return result
  } catch (error) {
    console.error("Error doTradeOpenService :", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    return {
      status: false,
      message: "Unexpected error occurred. Please refresh the page.",
    }
  }
}
