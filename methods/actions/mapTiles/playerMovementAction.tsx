"use server"

import { auth } from "@/auth"
import { cancelTasks, insertTasks } from "@/db/postgresMainDatabase/schemas/tasks/tasks"
import { isMovementPathNeighborhoodTile } from "@/methods/functions/isMovementPathNeighborhoodTile"
import { TMapTilesMovementPathSet } from "@/methods/hooks/mapTiles/composite/useActionMapTilesMovement"

export type TPlayerMovementAction = {
  playerId: number
  x: number
  y: number
}

export async function playerMovementAction(parameters: TMapTilesMovementPathSet) {
  const methodName = "map.movementAction"
  const session = await auth()
  const sessionPlayerId = session?.user?.playerId

  if (!sessionPlayerId || isNaN(sessionPlayerId)) {
    return
  }

  const path = Array.from(parameters).map((tile) => {
    const [x, y] = tile.split(",").map(Number)
    return { x, y }
  })

  if (!isMovementPathNeighborhoodTile(path)) {
    console.warn("Invalid movement path:", path)
    return "Invalid movement path"
  }

  try {
    await cancelTasks({ playerId: sessionPlayerId, methodName })

    for (let i = 1; i < path.length; i++) {
      const param = path[i]
      await insertTasks<TPlayerMovementAction>({ playerId: sessionPlayerId, methodName, parameters: { playerId: sessionPlayerId, x: param.x, y: param.y } })
    }
  } catch (error) {
    console.error("Error movementAction :", error)
    return "Failed to movementAction"
  }
}
