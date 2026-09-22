// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/lib/auth"
import { TDoMoveOrSwapItemServiceParams, doMoveOrSwapItemService } from "@/methods/services/inventory/doMoveOrSwapItemService"
import { headers } from "next/headers"

type TDoMoveOrSwapItemActionParams = Omit<TDoMoveOrSwapItemServiceParams, "userId">

export async function doMoveOrSwapItemAction(params: TDoMoveOrSwapItemActionParams) {
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

    const data: TDoMoveOrSwapItemServiceParams = {
      userId: sessionUserId,
      ...params,
    }

    const result = await doMoveOrSwapItemService(data)
    return result
  } catch (error) {
    console.error("Error doMoveOrSwapItemAction :", {
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