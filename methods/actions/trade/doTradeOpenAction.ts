// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/lib/auth"
import { TDoTradeOpenServiceParams, doTradeOpenService } from "@/methods/services/trade/doTradeOpenService"
import { headers } from "next/headers"

type TDoTradeOpenActionParams = Omit<TDoTradeOpenServiceParams, "userId">

export async function doTradeOpenAction(params: TDoTradeOpenActionParams) {
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

    const data: TDoTradeOpenServiceParams = {
      userId: sessionUserId,
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