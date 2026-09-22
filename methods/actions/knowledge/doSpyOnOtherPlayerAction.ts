// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/lib/auth"
import {
  TDoSpyOnOtherPlayerServiceParams,
  doSpyOnOtherPlayerService,
} from "@/methods/services/knowledge/doSpyOnOtherPlayerService"
import { headers } from "next/headers"

type TDoSpyOnOtherPlayerActionParams = Omit<TDoSpyOnOtherPlayerServiceParams, "userId">

export async function doSpyOnOtherPlayerAction(params: TDoSpyOnOtherPlayerActionParams) {
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

    const data: TDoSpyOnOtherPlayerServiceParams = {
      userId: sessionUserId,
      ...params,
    }

    const result = await doSpyOnOtherPlayerService(data)
    return result
  } catch (error) {
    console.error("Error doSpyOnOtherPlayerAction :", {
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
