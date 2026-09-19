// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import {
  TDoOtherPlayerKnowledgeAcceptParams,
  doOtherPlayerKnowledgeAccept,
} from "@/db/postgresMainDatabase/schemas/knowledge/doOtherPlayerKnowledgeAccept"

//MANUAL CODE - START

export type TDoOtherPlayerKnowledgeAcceptServiceParams = {
  sessionUserId: string
  playerId: number
  inviteId: number
}

//MANUAL CODE - END

export async function doOtherPlayerKnowledgeAcceptService(params: TDoOtherPlayerKnowledgeAcceptServiceParams) {
  try {
    const sessionPlayerId = params.sessionUserId
    const playerId = params.playerId

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
