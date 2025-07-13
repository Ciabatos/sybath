"use client"

import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useMapTilesArea } from "@/methods/hooks/mapTiles/core/useMapTilesArea"
import { mapTilesGuardAreaSetAtom } from "@/store/atoms"
import { useAtom } from "jotai"

export type TMapTilesGuardAreaSet = Set<string>

export function useActionMapTilesGuardArea() {
  const { areaFromPoint } = useMapTilesArea()
  const [mapTilesGuardAreaSet, setMapTilesGuardAreaSet] = useAtom(mapTilesGuardAreaSetAtom)

  function selectMapTilesGuardArea(startingPoint: TJoinedMapTile | undefined, clickedTile: TJoinedMapTile | undefined) {
    if (startingPoint && clickedTile) {
      const guardArea = areaFromPoint(clickedTile.mapTile.x, clickedTile.mapTile.y, 1)
      const guardAreaSet = new Set(guardArea.map((tile) => `${tile.mapTile.x},${tile.mapTile.y}`))
      setMapTilesGuardAreaSet(guardAreaSet)
    }
  }

  return { selectMapTilesGuardArea, mapTilesGuardAreaSet }
}
