// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoSquadJoinParams, doSquadJoin } from "@/db/postgresMainDatabase/schemas/squad/doSquadJoin"
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"

//MANUAL CODE - START

export type TDoSquadJoinServiceParams = {
  sessionUserId: number
  playerId: number
  squadInviteId: number
}

//MANUAL CODE - END

export async function doSquadJoinService(params: TDoSquadJoinServiceParams) {
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
