// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoTradeOpenParams, doTradeOpen } from "@/db/postgresMainDatabase/schemas/trade/doTradeOpen"
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"

//MANUAL CODE - START

export type TDoTradeOpenServiceParams = {
  sessionUserId: number
  playerId: number
  invitedPlayerId: string
}

//MANUAL CODE - END

export async function doTradeOpenService(params: TDoTradeOpenServiceParams) {
  try {
    const sessionPlayerId = (await getActivePlayerServer({ userId: params.sessionUserId }, { forceFresh: true })).raw[0]
      .id
    const playerId = params.playerId

    if (sessionPlayerId !== playerId) {
      return {
        status: false,
        message: "Active player mismatch",
      }
    }

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
