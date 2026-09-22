// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/lib/auth"
import { TDoSquadJoinServiceParams, doSquadJoinService } from "@/methods/services/squad/doSquadJoinService"
import { headers } from "next/headers"

type TDoSquadJoinActionParams = Omit<TDoSquadJoinServiceParams, "userId">

export async function doSquadJoinAction(params: TDoSquadJoinActionParams) {
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

    const data: TDoSquadJoinServiceParams = {
      userId: sessionUserId,
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