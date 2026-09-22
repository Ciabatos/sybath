// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import {
  TDoOtherPlayerKnowledgeAcceptParams,
  doOtherPlayerKnowledgeAccept,
} from "@/db/postgresMainDatabase/schemas/knowledge/doOtherPlayerKnowledgeAccept"

//MANUAL CODE - START

export type TDoOtherPlayerKnowledgeAcceptServiceParams = {
  userId: string
  playerId: number
  inviteId: number
}

//MANUAL CODE - END

export async function doOtherPlayerKnowledgeAcceptService(params: TDoOtherPlayerKnowledgeAcceptServiceParams) {
  try {
    const userId = params.userId
    const playerId = params.playerId

    //MANUAL CODE - START

    const inviteId = params.inviteId

    //MANUAL CODE - END

    const data: TDoOtherPlayerKnowledgeAcceptParams = {
      userId: userId,
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
