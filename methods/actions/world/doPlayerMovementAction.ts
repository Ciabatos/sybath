// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import { TDoPlayerMovementParams, doPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/doPlayerMovement"

//MANUAL CODE - START

type TDoPlayerMovementActionParams = {

}

//MANUAL CODE - END

export async function doPlayerMovementAction(params: TDoPlayerMovementActionParams) {
  const session = await auth()
  const playerId = session?.user?.playerId

  if (!playerId || isNaN(playerId)) {
    return
  }

  //MANUAL CODE - START

  const playerId =
  const path =

  //MANUAL CODE - END

  const data: TDoPlayerMovementParams = {
    playerId: playerId,
    path: path,
  }

  try {
    const result = await doPlayerMovement(data)
    return result
  } catch (error) {
    console.error("Error doPlayerMovementAction :", error)
    return "Failed to doPlayerMovementAction"
  }
}