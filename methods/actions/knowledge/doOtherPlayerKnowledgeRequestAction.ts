// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/lib/auth"
import {
  TDoOtherPlayerKnowledgeRequestServiceParams,
  doOtherPlayerKnowledgeRequestService,
} from "@/methods/services/knowledge/doOtherPlayerKnowledgeRequestService"
import { headers } from "next/headers"

type TDoOtherPlayerKnowledgeRequestActionParams = Omit<TDoOtherPlayerKnowledgeRequestServiceParams, "userId">

export async function doOtherPlayerKnowledgeRequestAction(params: TDoOtherPlayerKnowledgeRequestActionParams) {
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

    const data: TDoOtherPlayerKnowledgeRequestServiceParams = {
      userId: sessionUserId,
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
