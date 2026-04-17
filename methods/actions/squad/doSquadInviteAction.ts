// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import { TDoSquadInviteServiceParams, doSquadInviteService } from "@/methods/services/squad/doSquadInviteService"

type TDoSquadInviteActionParams = Omit<TDoSquadInviteServiceParams, "sessionUserId">

export async function doSquadInviteAction(params: TDoSquadInviteActionParams) {
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

    const data: TDoSquadInviteServiceParams = {
      sessionUserId: sessionUserId,
      ...params,
    }

    const result = await doSquadInviteService(data)
    return result
  } catch (error) {
    console.error("Error doSquadInviteAction :", {
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
