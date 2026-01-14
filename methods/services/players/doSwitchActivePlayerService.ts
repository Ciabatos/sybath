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
  const sessionPlayerId = (await getActivePlayerServer({ userId: params.sessionUserId })).raw[0].id

  if (sessionPlayerId !== params.playerId) {
    throw new Error("Active player mismatch")
  }

  //MANUAL CODE - START

  const playerId = params.playerId
  const switchToPlayerId = params.switchToPlayerId

  if (playerId === switchToPlayerId) {
    throw new Error("Cannot switch to the same player")
  }

  const playerIds = session.user.playerIds || []

  if (!playerIds.includes(playerId) || !playerIds.includes(switchToPlayerId)) {
    throw new Error("Cannot switch")
  }
  //MANUAL CODE - END

  const data: TDoSwitchActivePlayerParams = {
    playerId: playerId,
    switchToPlayerId: switchToPlayerId,
  }

  try {
    const result = await doSwitchActivePlayer(data)
    return result
  } catch (error) {
    console.error("Error doSwitchActivePlayerService :", error)
    return "Failed to doSwitchActivePlayerService"
  }
}
