// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/lib/auth"
import { TDoSquadCreateServiceParams, doSquadCreateService } from "@/methods/services/squad/doSquadCreateService"
import { headers } from "next/headers"

type TDoSquadCreateActionParams = Omit<TDoSquadCreateServiceParams, "userId">

export async function doSquadCreateAction(params: TDoSquadCreateActionParams) {
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

    const data: TDoSquadCreateServiceParams = {
      userId: sessionUserId,
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