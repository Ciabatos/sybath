// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import {
  TDoOtherPlayerKnowledgeAcceptParams,
  doOtherPlayerKnowledgeAccept,
} from "@/db/postgresMainDatabase/schemas/knowledge/doOtherPlayerKnowledgeAccept"
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"

//MANUAL CODE - START

export type TDoOtherPlayerKnowledgeAcceptServiceParams = {
  sessionUserId: number
  playerId: number
  inviteId: number
}

//MANUAL CODE - END

export async function doOtherPlayerKnowledgeAcceptService(params: TDoOtherPlayerKnowledgeAcceptServiceParams) {
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

    const inviteId = params.inviteId

    //MANUAL CODE - END

    const data: TDoOtherPlayerKnowledgeAcceptParams = {
      playerId: playerId,
      inviteId: inviteId,
    }

    const result = await doOtherPlayerKnowledgeAccept(data)
    return result
  } catch (error) {
    console.error("Error doOtherPlayerKnowledgeAcceptService :", {
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
