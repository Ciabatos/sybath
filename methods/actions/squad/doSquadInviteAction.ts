// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/lib/auth"
import { TDoSquadInviteServiceParams, doSquadInviteService } from "@/methods/services/squad/doSquadInviteService"
import { headers } from "next/headers"

type TDoSquadInviteActionParams = Omit<TDoSquadInviteServiceParams, "userId">

export async function doSquadInviteAction(params: TDoSquadInviteActionParams) {
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

    const data: TDoSquadInviteServiceParams = {
      userId: sessionUserId,
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
