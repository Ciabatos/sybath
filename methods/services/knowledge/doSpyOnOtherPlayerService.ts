// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoSpyOnOtherPlayerParams, doSpyOnOtherPlayer } from "@/db/postgresMainDatabase/schemas/knowledge/doSpyOnOtherPlayer"

//MANUAL CODE - START

export type TDoSpyOnOtherPlayerServiceParams = {
userId: string
playerId: number
}

//MANUAL CODE - END

export async function doSpyOnOtherPlayerService(params: TDoSpyOnOtherPlayerServiceParams) {
  try {
    const userId = params.userId
    const playerId = params.playerId

    //MANUAL CODE - START

    const userId =
    const playerId =
    const otherPlayerId =
    const knowledgeTypeId =

    //MANUAL CODE - END

    const data: TDoSpyOnOtherPlayerParams = {
      userId: userId,
      playerId: playerId,
      otherPlayerId: otherPlayerId,
      knowledgeTypeId: knowledgeTypeId,
    }

    const result = await doSpyOnOtherPlayer(data)
    return result
  } catch (error) {
    console.error("Error doSpyOnOtherPlayerService :", {
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