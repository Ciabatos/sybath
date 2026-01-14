// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import {
  TDoSwitchActivePlayerServiceParams,
  doSwitchActivePlayerService,
} from "@/methods/services/players/doSwitchActivePlayerService"

export async function doSwitchActivePlayerAction(params: TDoSwitchActivePlayerServiceParams) {
  const session = await auth()
  const sessionUserId = session?.user?.userId

  if (!sessionUserId || isNaN(sessionUserId)) {
    return
  }

  //MANUAL CODE - START

  //MANUAL CODE - END

  const data: TDoSwitchActivePlayerServiceParams = {
    sessionUserId: sessionUserId,
    ...params,
  }

  try {
    const result = await doSwitchActivePlayerService(data)
    return result
  } catch (error) {
    console.error("Error doSwitchActivePlayerAction :", error)
    return "Failed to doSwitchActivePlayerAction"
  }
}
