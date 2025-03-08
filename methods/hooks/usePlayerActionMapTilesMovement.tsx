"use client"

import { useAStar } from "@/methods/hooks/useAStar"
import type { TClickedTile } from "@/methods/hooks/useClickTile"

//zmiana statusu po kliknieciu button Movment
//startowa pozycja 1 klikniecie
//koncowa pozycja 2 klikniecie
//policz astar
//pokoloruj path

export function usePlayerActionMapTilesMovement() {
  const { runAStar } = useAStar()

  function playerActionMapTilesMovement(startingPoint: TClickedTile, endingPoint: TClickedTile) {
    if (!startingPoint || !endingPoint) return
    const movmentPath = runAStar(startingPoint!.x, startingPoint!.y, endingPoint!.x, endingPoint!.y, 0)
    console.log(movmentPath)
    console.log(startingPoint)
    console.log(endingPoint)
  }
  return { playerActionMapTilesMovement }
}
