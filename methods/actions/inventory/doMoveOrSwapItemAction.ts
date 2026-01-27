// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import {
  TDoMoveOrSwapItemServiceParams,
  doMoveOrSwapItemService,
} from "@/methods/services/inventory/doMoveOrSwapItemService"

type TDoMoveOrSwapItemActionParams = Omit<TDoMoveOrSwapItemServiceParams, "sessionUserId">

export async function doMoveOrSwapItemAction(params: TDoMoveOrSwapItemActionParams) {
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

    const data: TDoMoveOrSwapItemServiceParams = {
      sessionUserId: sessionUserId,
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
