// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoSquadJoinParams, doSquadJoin } from "@/db/postgresMainDatabase/schemas/squad/doSquadJoin"

//MANUAL CODE - START

export type TDoSquadJoinServiceParams = {
  userId: string
  playerId: number
  squadInviteId: number
}

//MANUAL CODE - END

export async function doSquadJoinService(params: TDoSquadJoinServiceParams) {
  try {
    const userId = params.userId
    const playerId = params.playerId

    //MANUAL CODE - START

    const squadInviteId = params.squadInviteId

    //MANUAL CODE - END

    const data: TDoSquadJoinParams = {
      userId: userId,
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
