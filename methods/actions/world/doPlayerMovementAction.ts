// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import { TDoPlayerMovementServiceParams, doPlayerMovementService } from "@/methods/services/world/doPlayerMovementService"

type TDoPlayerMovementActionParams = Omit<TDoPlayerMovementServiceParams, "sessionUserId">

export async function doPlayerMovementAction(params: TDoPlayerMovementActionParams) {
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

    const data: TDoPlayerMovementServiceParams = {
      sessionUserId: sessionUserId,
      ...params,
    }

    const result = await doPlayerMovementService(data)
    return result
  } catch (error) {
    console.error("Error doPlayerMovementAction :", {
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