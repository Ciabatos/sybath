// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoPlayerMovementParams, doPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/doPlayerMovement"

//MANUAL CODE - START

export type TDoPlayerMovementServiceParams = {
playerId: number
}

//MANUAL CODE - END

export async function doPlayerMovementService(params: TDoPlayerMovementServiceParams) {

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
    console.error("Error doPlayerMovementService :", error)
    return "Failed to doPlayerMovementService"
  }
}