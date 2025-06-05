"use server"

import { auth } from "@/auth"
import { cancelTasks, insertTasks } from "@/db/postgresMainDatabase/schemas/tasks/tasks"
import { isMovementPathNeighborhoodTile } from "@/methods/functions/isMovementPathNeighborhoodTile"
import { TMovementPath } from "@/methods/hooks/mapTiles/useMapTilesPath"

export type TPlayerMovementAction = {
  playerId: number
  x: number
  y: number
}

export async function playerMovementAction(parameters: TMovementPath[]) {
  const methodName = "map.movementAction"
  const session = await auth()
  const sessionPlayerId = session?.user?.playerId

  if (!sessionPlayerId || isNaN(sessionPlayerId)) {
    return
  }

  const path = parameters.map((p) => [p.mapTile.x, p.mapTile.y])

  if (!isMovementPathNeighborhoodTile(path)) {
    console.warn("Invalid movement path:", path)
    return "Invalid movement path"
  }

  try {
    await cancelTasks({ playerId: sessionPlayerId, methodName })

    for (const param of parameters) {
      const index = parameters.indexOf(param)
      // const totalMovementCost = param.totalMovementCost
      //dodac przeliczenie movementCost na czas
      if (index > 0) {
        await insertTasks<TPlayerMovementAction>({ playerId: sessionPlayerId, methodName, parameters: { playerId: sessionPlayerId, x: param.mapTile.x, y: param.mapTile.y } })
      }
    }
  } catch (error) {
    console.error("Error movementAction :", error)
    return "Failed to movementAction"
  }
}
