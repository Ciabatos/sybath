// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import {
  TDoSwitchActivePlayerParams,
  doSwitchActivePlayer,
} from "@/db/postgresMainDatabase/schemas/players/doSwitchActivePlayer"

//MANUAL CODE - START

export type TDoSwitchActivePlayerServiceParams = {
  playerId: number
  switchToPlayerId: number
}

//MANUAL CODE - END

export async function doSwitchActivePlayerService(params: TDoSwitchActivePlayerServiceParams) {
  //MANUAL CODE - START
  const session = await auth()

  if (!session?.user) {
    throw new Error("User not authenticated")
  }

  const playerId = session.user.playerId
  const switchToPlayerId = params.switchToPlayerId
  console.log("switchToPlayerId:", switchToPlayerId, "playerId:", playerId)
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
