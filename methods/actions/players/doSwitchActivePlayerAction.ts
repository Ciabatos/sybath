// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import {
  TDoSwitchActivePlayerServiceParams,
  doSwitchActivePlayerService,
} from "@/methods/services/players/doSwitchActivePlayerService"

type TDoSwitchActivePlayerActionParams = Omit<TDoSwitchActivePlayerServiceParams, "sessionUserId">

export async function doSwitchActivePlayerAction(params: TDoSwitchActivePlayerActionParams) {
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

    const data: TDoSwitchActivePlayerServiceParams = {
      sessionUserId: sessionUserId,
      ...params,
    }

    const result = await doSwitchActivePlayerService(data)
    return result
  } catch (error) {
    console.error("Error doSwitchActivePlayerAction :", {
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
