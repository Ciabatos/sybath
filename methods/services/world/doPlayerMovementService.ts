// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoPlayerMovementParams, doPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/doPlayerMovement"
import { pathFromPointToPoint } from "@/methods/functions/map/pathFromPointToPoint"
import { getJoinedMap } from "@/methods/server-fetchers/world/composite/getJoinedMap"

//MANUAL CODE - START

export type TDoPlayerMovementServiceParams = {
  playerId: number
  mapId: number
  startX: number
  startY: number
  endX: number
  endY: number
}

//MANUAL CODE - END

export async function doPlayerMovementService(params: TDoPlayerMovementServiceParams) {
  //MANUAL CODE - START

  const joinedMap = await getJoinedMap(params.mapId, params.playerId)

  if (!joinedMap) {
    return
  }
  const path = pathFromPointToPoint({
    startX: params.startX,
    startY: params.startY,
    endX: params.endX,
    endY: params.endY,
    mapTiles: joinedMap.joinedMap,
  })

  //MANUAL CODE - END

  const data: TDoPlayerMovementParams = {
    playerId: params.playerId,
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
