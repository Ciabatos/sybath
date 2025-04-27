"use client"

import type { TTileCoordinates } from "@/methods/hooks/useMapTileClick"
import { useMapTilesPath } from "@/methods/hooks/useMapTilesPath"
import { mapTilesMovmentPathAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"

export function useActionMapTilesMovement() {
  const { runAStar } = useMapTilesPath()
  const setMapTilesMovmentPath = useSetAtom(mapTilesMovmentPathAtom)

  function actionMapTilesMovement(startingPoint: TTileCoordinates, endingPoint: TTileCoordinates) {
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

  return { actionMapTilesMovement }
}
