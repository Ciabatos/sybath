"use client"

import type { TClickedTile } from "@/methods/hooks/useClickTile"
import { useMapTilesAreaFromPoint } from "@/methods/hooks/useMapTilesAreaFromPoint"
import { mapTilesGuardAreaAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"

export function usePlayerActionMapTilesGuardArea() {
  const { areaFromPoint } = useMapTilesAreaFromPoint()
  const setMapTilesGuardArea = useSetAtom(mapTilesGuardAreaAtom)

  function playerActionMapTilesGuardArea(startingPoint: TClickedTile) {
    if (!startingPoint) {
      console.warn("Starting point is missing.")
      return
    }
    const guardArea = areaFromPoint(startingPoint.x, startingPoint.y, 1)

    setMapTilesGuardArea(guardArea)
  }

  return { playerActionMapTilesGuardArea }
}
