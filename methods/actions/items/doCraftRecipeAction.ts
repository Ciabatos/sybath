// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import { TDoCraftRecipeServiceParams, doCraftRecipeService } from "@/methods/services/items/doCraftRecipeService"

type TDoCraftRecipeActionParams = Omit<TDoCraftRecipeServiceParams, "sessionUserId">

export async function doCraftRecipeAction(params: TDoCraftRecipeActionParams) {
  console.log("doCraftRecipeAction - params:", params)
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

    const data: TDoCraftRecipeServiceParams = {
      sessionUserId: sessionUserId,
      ...params,
    }

    const result = await doCraftRecipeService(data)
    return result
  } catch (error) {
    console.error("Error doCraftRecipeAction :", {
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
