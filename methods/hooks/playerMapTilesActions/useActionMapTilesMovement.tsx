"use client"

import { TTileCoordinates } from "@/methods/hooks/mapTiles/useMapTilesManipulation"
import { useMapTilesPath } from "@/methods/hooks/mapTiles/useMapTilesPath"
import { mapTilesMovmentPathAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"

export function useActionMapTilesMovement() {
  const { pathFromPointToPoint } = useMapTilesPath()
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
    const movmentPath = pathFromPointToPoint(startingPoint.x, startingPoint.y, endingPoint.x, endingPoint.y, 0)
    setMapTilesMovmentPath(movmentPath)
  }

  return { actionMapTilesMovement }
}
