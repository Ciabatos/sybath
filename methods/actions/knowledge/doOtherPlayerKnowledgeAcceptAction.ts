// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/lib/auth"
import {
  TDoOtherPlayerKnowledgeAcceptServiceParams,
  doOtherPlayerKnowledgeAcceptService,
} from "@/methods/services/knowledge/doOtherPlayerKnowledgeAcceptService"
import { headers } from "next/headers"

type TDoOtherPlayerKnowledgeAcceptActionParams = Omit<TDoOtherPlayerKnowledgeAcceptServiceParams, "sessionUserId">

export async function doOtherPlayerKnowledgeAcceptAction(params: TDoOtherPlayerKnowledgeAcceptActionParams) {
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

    const data: TDoOtherPlayerKnowledgeAcceptServiceParams = {
      sessionUserId: sessionUserId,
      ...params,
    }

    const result = await doOtherPlayerKnowledgeAcceptService(data)
    return result
  } catch (error) {
    console.error("Error doOtherPlayerKnowledgeAcceptAction :", {
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
