// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoSquadLeaveParams, doSquadLeave } from "@/db/postgresMainDatabase/schemas/squad/doSquadLeave"

//MANUAL CODE - START

export type TDoSquadLeaveServiceParams = {
  sessionUserId: string
  playerId: number
}

//MANUAL CODE - END

export async function doSquadLeaveService(params: TDoSquadLeaveServiceParams) {
  try {
    const sessionPlayerId = params.sessionUserId
    const playerId = params.playerId

    //MANUAL CODE - START

    //MANUAL CODE - END

    const data: TDoSquadLeaveParams = {
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
