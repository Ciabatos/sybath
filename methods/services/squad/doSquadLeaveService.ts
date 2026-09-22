// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoSquadLeaveParams, doSquadLeave } from "@/db/postgresMainDatabase/schemas/squad/doSquadLeave"

//MANUAL CODE - START

export type TDoSquadLeaveServiceParams = {
  userId: string
  playerId: number
}

//MANUAL CODE - END

export async function doSquadLeaveService(params: TDoSquadLeaveServiceParams) {
  try {
    const userId = params.userId
    const playerId = params.playerId

    //MANUAL CODE - START

    //MANUAL CODE - END

    const data: TDoSquadLeaveParams = {
      userId: userId,
      playerId: playerId,
    }

    const result = await doSquadLeave(data)
    return result
  } catch (error) {
    console.error("Error doSquadLeaveService :", {
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
