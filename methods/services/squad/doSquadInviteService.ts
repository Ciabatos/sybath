// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoSquadInviteParams, doSquadInvite } from "@/db/postgresMainDatabase/schemas/squad/doSquadInvite"
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"

//MANUAL CODE - START

export type TDoSquadInviteServiceParams = {
  sessionUserId: number
  playerId: number
  invitedPlayerId: string
  inviteType: number
  squadRole: number
}

//MANUAL CODE - END

export async function doSquadInviteService(params: TDoSquadInviteServiceParams) {
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
    const inviteType = params.inviteType
    const squadRole = params.squadRole

    //MANUAL CODE - END

    const data: TDoSquadInviteParams = {
      playerId: playerId,
      invitedPlayerId: invitedPlayerId,
      inviteType: inviteType,
      squadRole: squadRole,
    }

    const result = await doSquadInvite(data)
    return result
  } catch (error) {
    console.error("Error doSquadInviteService :", {
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
