// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoSquadCreateParams, doSquadCreate } from "@/db/postgresMainDatabase/schemas/squad/doSquadCreate"

//MANUAL CODE - START

export type TDoSquadCreateServiceParams = {
  userId: string
  playerId: number
}

//MANUAL CODE - END

export async function doSquadCreateService(params: TDoSquadCreateServiceParams) {
  try {
    const userId = params.userId
    const playerId = params.playerId

    //MANUAL CODE - START

    //MANUAL CODE - END

    const data: TDoSquadCreateParams = {
      userId: userId,
      playerId: playerId,
    }

    const result = await doSquadCreate(data)
    return result
  } catch (error) {
    console.error("Error doSquadCreateService :", {
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
