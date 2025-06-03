"use server"

import { auth } from "@/auth"
import { cancelTasks, insertTasks } from "@/db/postgresMainDatabase/schemas/tasks/tasks"
import { isMovementPathNeighborhoodTile } from "@/methods/functions/isMovementPathNeighborhoodTile"
import { TMovmentPath } from "@/methods/hooks/mapTiles/useMapTilesPath"

export type TPlayerMovmentAction = {
  playerId: number
  x: number
  y: number
}

export async function playerMovmentAction(parameters: TMovmentPath[]) {
  const methodName = "map.movmentAction"
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
      // const totalMovmentCost = param.totalMovmentCost
      //dodac przeliczenie movmentCost na czas
      if (index > 0) {
        await insertTasks<TPlayerMovmentAction>({ playerId: sessionPlayerId, methodName, parameters: { playerId: sessionPlayerId, x: param.mapTile.x, y: param.mapTile.y } })
      }
    }
  } catch (error) {
    console.error("Error movmentAction :", error)
    return "Failed to movmentAction"
  }
}
