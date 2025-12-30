// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import { doPlayerMovement, TDoPlayerMovementParams } from "@/db/postgresMainDatabase/schemas/world/doPlayerMovement"
import { pathFromPointToPoint } from "@/methods/functions/map/pathFromPointToPoint"
import { getJoinedMap } from "@/methods/server-fetchers/world/composite/getJoinedMap"

export type TPlayerMovementActionParams = {
  mapId: number
  startX: number
  startY: number
  endX: number
  endY: number
}

export async function playerMovementAction(params: TPlayerMovementActionParams) {
  const session = await auth()
  const playerId = session?.user?.playerId

  if (!playerId || isNaN(playerId)) {
    return
  }

  const joinedMap = await getJoinedMap(params.mapId, playerId)

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

  const data: TDoPlayerMovementParams = {
    playerId: playerId,
    path: path,
  }

  try {
    const result = await doPlayerMovement(data)
    return result
  } catch (error) {
    console.error("Error playerMovementAction :", error)
    return "Failed to playerMovementAction"
  }
}
