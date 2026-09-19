// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/lib/auth"
import { TDoSquadLeaveServiceParams, doSquadLeaveService } from "@/methods/services/squad/doSquadLeaveService"
import { headers } from "next/headers"

type TDoSquadLeaveActionParams = Omit<TDoSquadLeaveServiceParams, "sessionUserId">

export async function doSquadLeaveAction(params: TDoSquadLeaveActionParams) {
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

    const data: TDoSquadLeaveServiceParams = {
      sessionUserId: sessionUserId,
      ...params,
    }

    const result = await doSquadLeaveService(data)
    return result
  } catch (error) {
    console.error("Error doSquadLeaveAction :", {
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
