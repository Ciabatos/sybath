// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import { TDoSquadJoinServiceParams, doSquadJoinService } from "@/methods/services/squad/doSquadJoinService"

type TDoSquadJoinActionParams = Omit<TDoSquadJoinServiceParams, "sessionUserId">

export async function doSquadJoinAction(params: TDoSquadJoinActionParams) {
  try {
    const session = await auth()
    const sessionUserId = session?.user?.userId

    if (!sessionUserId || isNaN(sessionUserId)) {
      return {
        status: false,
        message: "Active player mismatch",
      }
    }

    //MANUAL CODE - START

    //MANUAL CODE - END

    const data: TDoSquadJoinServiceParams = {
      sessionUserId: sessionUserId,
      ...params,
    }

    const result = await doSquadJoinService(data)
    return result
  } catch (error) {
    console.error("Error doSquadJoinAction :", {
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
