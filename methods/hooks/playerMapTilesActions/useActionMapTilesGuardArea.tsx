"use client"

import { useMapTilesArea } from "@/methods/hooks/mapTiles/useMapTilesArea"
import { TTileCoordinates } from "@/methods/hooks/mapTiles/useMapTilesManipulation"
import { mapTilesGuardAreaAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"

export function useActionMapTilesGuardArea() {
  const { areaFromPoint } = useMapTilesArea()
  const setMapTilesGuardArea = useSetAtom(mapTilesGuardAreaAtom)

  function actionMapTilesGuardArea(startingPoint: TTileCoordinates) {
    if (!startingPoint) {
      console.warn("Starting point is missing.")
      return
    }
    const guardArea = areaFromPoint(startingPoint.x, startingPoint.y, 1)

    setMapTilesGuardArea(guardArea)
  }

  return { actionMapTilesGuardArea }
}
