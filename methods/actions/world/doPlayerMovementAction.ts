// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import {
  TDoPlayerMovementServiceParams,
  doPlayerMovementService,
} from "@/methods/services/world/doPlayerMovementService"

export async function doPlayerMovementAction(params: TDoPlayerMovementServiceParams) {
  const session = await auth()
  const sessionUserId = session?.user?.userId

  if (!sessionUserId || isNaN(sessionUserId)) {
    return
  }

  //MANUAL CODE - START

  //MANUAL CODE - END

  const data: TDoPlayerMovementServiceParams = {
    ...params,
  }

  try {
    const result = await doPlayerMovementService(data)
    return result
  } catch (error) {
    console.error("Error doPlayerMovementAction :", error)
    return "Failed to doPlayerMovementAction"
  }
}
