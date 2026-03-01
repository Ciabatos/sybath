// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import {
  TDoGatherResourcesOnMapTileServiceParams,
  doGatherResourcesOnMapTileService,
} from "@/methods/services/items/doGatherResourcesOnMapTileService"

type TDoGatherResourcesOnMapTileActionParams = Omit<TDoGatherResourcesOnMapTileServiceParams, "sessionUserId">

export async function doGatherResourcesOnMapTileAction(params: TDoGatherResourcesOnMapTileActionParams) {
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

    const data: TDoGatherResourcesOnMapTileServiceParams = {
      sessionUserId: sessionUserId,
      ...params,
    }

    const result = await doGatherResourcesOnMapTileService(data)
    return result
  } catch (error) {
    console.error("Error doGatherResourcesOnMapTileAction :", {
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
