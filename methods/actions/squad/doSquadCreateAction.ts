// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import { TDoSquadCreateServiceParams, doSquadCreateService } from "@/methods/services/squad/doSquadCreateService"

type TDoSquadCreateActionParams = Omit<TDoSquadCreateServiceParams, "sessionUserId">

export async function doSquadCreateAction(params: TDoSquadCreateActionParams) {
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

    const data: TDoSquadCreateServiceParams = {
      sessionUserId: sessionUserId,
      ...params,
    }

    const result = await doSquadCreateService(data)
    return result
  } catch (error) {
    console.error("Error doSquadCreateAction :", {
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
