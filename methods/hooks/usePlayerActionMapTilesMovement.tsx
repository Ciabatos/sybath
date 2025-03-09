"use client"

import { useAStar } from "@/methods/hooks/useAStar"
import type { TClickedTile } from "@/methods/hooks/useClickTile"
import { mapTilesMovmentPathAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"

export function usePlayerActionMapTilesMovement() {
  const { runAStar } = useAStar()
  const setMapTilesMovmentPath = useSetAtom(mapTilesMovmentPathAtom)

  function playerActionMapTilesMovement(startingPoint: TClickedTile, endingPoint: TClickedTile) {
    if (!startingPoint) {
      console.warn("Starting point is missing.")
      return
    }
    if (!endingPoint) {
      console.warn("Ending point is missing.")
      return
    }
    const movmentPath = runAStar(startingPoint.x, startingPoint.y, endingPoint.x, endingPoint.y, 0)

    setMapTilesMovmentPath(movmentPath)
  }

  return { playerActionMapTilesMovement }
}
