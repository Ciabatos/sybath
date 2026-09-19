// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoSquadJoinParams, doSquadJoin } from "@/db/postgresMainDatabase/schemas/squad/doSquadJoin"

//MANUAL CODE - START

export type TDoSquadJoinServiceParams = {
  sessionUserId: string
  playerId: number
  squadInviteId: number
}

//MANUAL CODE - END

export async function doSquadJoinService(params: TDoSquadJoinServiceParams) {
  try {
    const sessionPlayerId = params.sessionUserId
    const playerId = params.playerId

    //MANUAL CODE - START

    const squadInviteId = params.squadInviteId

    //MANUAL CODE - END

    const data: TDoSquadJoinParams = {
      playerId: playerId,
      squadInviteId: squadInviteId,
    }

    const result = await doSquadJoin(data)
    return result
  } catch (error) {
    console.error("Error doSquadJoinService :", {
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
