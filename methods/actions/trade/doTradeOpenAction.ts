// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import { TDoTradeOpenServiceParams, doTradeOpenService } from "@/methods/services/trade/doTradeOpenService"

type TDoTradeOpenActionParams = Omit<TDoTradeOpenServiceParams, "sessionUserId">

export async function doTradeOpenAction(params: TDoTradeOpenActionParams) {
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

    const data: TDoTradeOpenServiceParams = {
      sessionUserId: sessionUserId,
      ...params,
    }

    const result = await doTradeOpenService(data)
    return result
  } catch (error) {
    console.error("Error doTradeOpenAction :", {
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
