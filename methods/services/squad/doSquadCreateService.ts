// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoSquadCreateParams, doSquadCreate } from "@/db/postgresMainDatabase/schemas/squad/doSquadCreate"
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"

//MANUAL CODE - START

export type TDoSquadCreateServiceParams = {
  sessionUserId: number
  playerId: number
}

//MANUAL CODE - END

export async function doSquadCreateService(params: TDoSquadCreateServiceParams) {
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

    //MANUAL CODE - END

    const data: TDoSquadCreateParams = {
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
