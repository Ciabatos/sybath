"use client"

import { useMapTileActions } from "@/methods/hooks/mapTiles/composite/useMapTileActions"
import { useMapTilesArea } from "@/methods/hooks/mapTiles/core/useMapTilesArea"
import { mapTilesGuardAreaAtom, mapTilesGuardAreaSetAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useState } from "react"

export function useActionMapTilesGuardArea() {
  const { clickedTile } = useMapTileActions()
  const [startingPoint] = useState(clickedTile)
  const { areaFromPoint } = useMapTilesArea()
  const setMapTilesGuardAreaSet = useSetAtom(mapTilesGuardAreaSetAtom)
  const mapTilesGuardAreaSet = useAtomValue(mapTilesGuardAreaSetAtom)
  const setMapTilesGuardArea = useSetAtom(mapTilesGuardAreaAtom)
  // const mapTilesGuardArea = useAtomValue(mapTilesGuardAreaAtom) // This is not used in this hook, but might be useful in action

  useEffect(() => {
    if (startingPoint && clickedTile) {
      const guardArea = areaFromPoint(clickedTile.mapTile.x, clickedTile.mapTile.y, 1)
      setMapTilesGuardArea(guardArea)
      const guardAreaSet = new Set(guardArea.map((tile) => `${tile.mapTile.x},${tile.mapTile.y}`))
      setMapTilesGuardAreaSet(guardAreaSet)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  return {
    mapTilesGuardAreaSet,
  }
}
