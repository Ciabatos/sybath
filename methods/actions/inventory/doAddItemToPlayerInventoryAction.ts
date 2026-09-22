// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/lib/auth"
import {
  TDoAddItemToPlayerInventoryServiceParams,
  doAddItemToPlayerInventoryService,
} from "@/methods/services/inventory/doAddItemToPlayerInventoryService"
import { headers } from "next/headers"

type TDoAddItemToPlayerInventoryActionParams = Omit<TDoAddItemToPlayerInventoryServiceParams, "userId">

export async function doAddItemToPlayerInventoryAction(params: TDoAddItemToPlayerInventoryActionParams) {
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

    const data: TDoAddItemToPlayerInventoryServiceParams = {
      userId: sessionUserId,
      ...params,
    }

    const result = await doAddItemToPlayerInventoryService(data)
    return result
  } catch (error) {
    console.error("Error doAddItemToPlayerInventoryAction :", {
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
