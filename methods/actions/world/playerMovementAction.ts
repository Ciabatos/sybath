// GENERATED CODE - DO NOT EDIT MANUALLY - actionGetMethodAction.hbs
"use server"

import { auth } from "@/auth"
import { TPlayerMovementParams, playerMovement } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { TJoinMap } from "@/methods/functions/map/joinMap"
import { pathFromPointToPoint } from "@/methods/functions/map/pathFromPointToPoint"
import { getJoinedMap } from "@/methods/server-fetchers/world/composite/getJoinedMap"

export async function playerMovementAction(startingPoint: TJoinMap, clickedTile: TJoinMap) {
  const session = await auth()
  const playerId = session?.user?.playerId
  const joinedMap = await getJoinedMap(startingPoint.tiles.mapId)

  if (!playerId || isNaN(playerId)) {
    return
  }

  const path = pathFromPointToPoint(startingPoint.tiles.x, startingPoint.tiles.y, clickedTile.tiles.x, clickedTile.tiles.y, 0, joinedMap)

  const data: TPlayerMovementParams = {
    playerId: playerId,
    path: path,
  }

  try {
    const result = await playerMovement(data)
    return result
  } catch (error) {
    console.error("Error playerMovementAction :", error)
    return "Failed to playerMovementAction"
  }
}
