// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoOtherPlayerKnowledgeRequestParams, doOtherPlayerKnowledgeRequest } from "@/db/postgresMainDatabase/schemas/knowledge/doOtherPlayerKnowledgeRequest"
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"

//MANUAL CODE - START

export type TDoOtherPlayerKnowledgeRequestServiceParams = {
sessionUserId: number
playerId: number
}

//MANUAL CODE - END

export async function doOtherPlayerKnowledgeRequestService(params: TDoOtherPlayerKnowledgeRequestServiceParams) {
  try {
    const sessionPlayerId = (await getActivePlayerServer({ userId: params.sessionUserId }, { forceFresh: true })).raw[0].id
    const playerId = params.playerId

    if (sessionPlayerId !== playerId) {
      return {
        status: false,
        message: "Active player mismatch",
      }
    }

    //MANUAL CODE - START

    const playerId =
    const otherPlayerId =
    const knowledgeTypeId =

    //MANUAL CODE - END

    const data: TDoOtherPlayerKnowledgeRequestParams = {
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