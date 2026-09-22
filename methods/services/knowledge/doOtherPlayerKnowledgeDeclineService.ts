// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import {
  TDoOtherPlayerKnowledgeDeclineParams,
  doOtherPlayerKnowledgeDecline,
} from "@/db/postgresMainDatabase/schemas/knowledge/doOtherPlayerKnowledgeDecline"

//MANUAL CODE - START

export type TDoOtherPlayerKnowledgeDeclineServiceParams = {
  userId: string
  playerId: number
  inviteId: number
}

//MANUAL CODE - END

export async function doOtherPlayerKnowledgeDeclineService(params: TDoOtherPlayerKnowledgeDeclineServiceParams) {
  try {
    const userId = params.userId
    const playerId = params.playerId

    //MANUAL CODE - START

    const inviteId = params.inviteId

    //MANUAL CODE - END

    const data: TDoOtherPlayerKnowledgeDeclineParams = {
      userId: userId,
      playerId: playerId,
      inviteId: inviteId,
    }

    const result = await doOtherPlayerKnowledgeDecline(data)
    return result
  } catch (error) {
    console.error("Error doOtherPlayerKnowledgeDeclineService :", {
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
