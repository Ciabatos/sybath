// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/lib/auth"
import {
  TDoOtherPlayerKnowledgeDeclineServiceParams,
  doOtherPlayerKnowledgeDeclineService,
} from "@/methods/services/knowledge/doOtherPlayerKnowledgeDeclineService"
import { headers } from "next/headers"

type TDoOtherPlayerKnowledgeDeclineActionParams = Omit<TDoOtherPlayerKnowledgeDeclineServiceParams, "sessionUserId">

export async function doOtherPlayerKnowledgeDeclineAction(params: TDoOtherPlayerKnowledgeDeclineActionParams) {
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

    const data: TDoOtherPlayerKnowledgeDeclineServiceParams = {
      sessionUserId: sessionUserId,
      ...params,
    }

    const result = await doOtherPlayerKnowledgeDeclineService(data)
    return result
  } catch (error) {
    console.error("Error doOtherPlayerKnowledgeDeclineAction :", {
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
