// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import {
  TDoOtherPlayerKnowledgeRequestParams,
  doOtherPlayerKnowledgeRequest,
} from "@/db/postgresMainDatabase/schemas/knowledge/doOtherPlayerKnowledgeRequest"

//MANUAL CODE - START

export type TDoOtherPlayerKnowledgeRequestServiceParams = {
  userId: string
  playerId: number
  otherPlayerId: string
  knowledgeTypeId: number
}

//MANUAL CODE - END

export async function doOtherPlayerKnowledgeRequestService(params: TDoOtherPlayerKnowledgeRequestServiceParams) {
  try {
    const userId = params.userId
    const playerId = params.playerId

    //MANUAL CODE - START

    const otherPlayerId = params.otherPlayerId
    const knowledgeTypeId = params.knowledgeTypeId

    //MANUAL CODE - END

    const data: TDoOtherPlayerKnowledgeRequestParams = {
      userId: userId,
      playerId: playerId,
      otherPlayerId: otherPlayerId,
      knowledgeTypeId: knowledgeTypeId,
    }

    const result = await doOtherPlayerKnowledgeRequest(data)
    return result
  } catch (error) {
    console.error("Error doOtherPlayerKnowledgeRequestService :", {
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
