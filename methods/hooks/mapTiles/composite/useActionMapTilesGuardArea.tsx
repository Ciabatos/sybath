"use client"

import { useMapTileActions } from "@/methods/hooks/mapTiles/composite/useMapTileActions"
import { useMapTilesArea } from "@/methods/hooks/mapTiles/core/useMapTilesArea"
import { mapTilesGuardAreaSetAtom } from "@/store/atoms"
import { useAtom } from "jotai"
import { useEffect, useState } from "react"

export function useActionMapTilesGuardArea() {
  const { clickedTile } = useMapTileActions()
  const [startingPoint] = useState(clickedTile)
  const { areaFromPoint } = useMapTilesArea()
  const [mapTilesGuardAreaSet, setMapTilesGuardAreaSet] = useAtom(mapTilesGuardAreaSetAtom)

  useEffect(() => {
    if (startingPoint && clickedTile) {
      const guardArea = areaFromPoint(clickedTile.mapTile.x, clickedTile.mapTile.y, 1)
      const guardAreaSet = new Set(guardArea.map((tile) => `${tile.mapTile.x},${tile.mapTile.y}`))
      setMapTilesGuardAreaSet(guardAreaSet)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  return {
    mapTilesGuardAreaSet,
  }
}
