// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/lib/auth"
import { TDoAddItemToInventoryServiceParams, doAddItemToInventoryService } from "@/methods/services/inventory/doAddItemToInventoryService"
import { headers } from "next/headers"

type TDoAddItemToInventoryActionParams = Omit<TDoAddItemToInventoryServiceParams, "userId">

export async function doAddItemToInventoryAction(params: TDoAddItemToInventoryActionParams) {
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

    const data: TDoAddItemToInventoryServiceParams = {
      userId: sessionUserId,
      ...params,
    }

    const result = await doAddItemToInventoryService(data)
    return result
  } catch (error) {
    console.error("Error doAddItemToInventoryAction :", {
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