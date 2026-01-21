// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import {
  TDoSwitchActivePlayerParams,
  doSwitchActivePlayer,
} from "@/db/postgresMainDatabase/schemas/players/doSwitchActivePlayer"
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"

//MANUAL CODE - START

export type TDoSwitchActivePlayerServiceParams = {
  sessionUserId: number
  playerId: number
  switchToPlayerId: number
}

//MANUAL CODE - END

export async function doSwitchActivePlayerService(params: TDoSwitchActivePlayerServiceParams) {
  try {
    const sessionPlayerId = (await getActivePlayerServer({ userId: params.sessionUserId })).raw[0].id
    const playerId = params.playerId

    if (sessionPlayerId !== playerId) {
      return {
        status: false,
        message: "Active player mismatch",
      }
    }

    //MANUAL CODE - START

    const switchToPlayerId = params.switchToPlayerId

    if (playerId === switchToPlayerId) {
      return {
        status: false,
        message: "Cannot switch to the same player",
      }
    }

    //MANUAL CODE - END

    const data: TDoSwitchActivePlayerParams = {
      playerId: playerId,
      switchToPlayerId: switchToPlayerId,
    }

    const result = await doSwitchActivePlayer(data)
    return result
  } catch (error) {
    console.error("Error doSwitchActivePlayerService :", {
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
