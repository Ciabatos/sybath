// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import {
  TDoSwitchActivePlayerServiceParams,
  doSwitchActivePlayerService,
} from "@/methods/services/players/doSwitchActivePlayerService"

type TDoSwitchActivePlayerActionParams = Omit<TDoSwitchActivePlayerServiceParams, "playerId">

export async function doSwitchActivePlayerAction(params: TDoSwitchActivePlayerActionParams) {
  const session = await auth()
  const playerId = session?.user?.playerId

  if (!playerId || isNaN(playerId)) {
    return
  }

  //MANUAL CODE - START

  //MANUAL CODE - END

  const data: TDoSwitchActivePlayerServiceParams = {
    playerId: playerId,
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
