// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/lib/auth"
import {
  TDoPlayerMovementServiceParams,
  doPlayerMovementService,
} from "@/methods/services/world/doPlayerMovementService"
import { headers } from "next/headers"

type TDoPlayerMovementActionParams = Omit<TDoPlayerMovementServiceParams, "userId">

export async function doPlayerMovementAction(params: TDoPlayerMovementActionParams) {
  try {
    const session = await auth.api.getSession({ headers: await headers() })
    const sessionUserId = session?.user?.id

    if (!sessionUserId) {
      return {
        status: false,
        message: "Active player mismatch",
      }
    }

    //MANUAL CODE - START

    //MANUAL CODE - END

    const data: TDoPlayerMovementServiceParams = {
      userId: sessionUserId,
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
