// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import {
  TDoOtherPlayerKnowledgeRequestServiceParams,
  doOtherPlayerKnowledgeRequestService,
} from "@/methods/services/players/doOtherPlayerKnowledgeRequestService"

type TDoOtherPlayerKnowledgeRequestActionParams = Omit<TDoOtherPlayerKnowledgeRequestServiceParams, "sessionUserId">

export async function doOtherPlayerKnowledgeRequestAction(params: TDoOtherPlayerKnowledgeRequestActionParams) {
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

    const data: TDoOtherPlayerKnowledgeRequestServiceParams = {
      sessionUserId: sessionUserId,
      ...params,
    }

    const result = await doOtherPlayerKnowledgeRequestService(data)
    return result
  } catch (error) {
    console.error("Error doOtherPlayerKnowledgeRequestAction :", {
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
