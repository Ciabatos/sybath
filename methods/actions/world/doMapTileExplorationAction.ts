// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import {
  TDoMapTileExplorationServiceParams,
  doMapTileExplorationService,
} from "@/methods/services/world/doMapTileExplorationService"

type TDoMapTileExplorationActionParams = Omit<TDoMapTileExplorationServiceParams, "sessionUserId">

export async function doMapTileExplorationAction(params: TDoMapTileExplorationActionParams) {
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

    const data: TDoMapTileExplorationServiceParams = {
      sessionUserId: sessionUserId,
      ...params,
    }

    const result = await doMapTileExplorationService(data)
    return result
  } catch (error) {
    console.error("Error doMapTileExplorationAction :", {
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
