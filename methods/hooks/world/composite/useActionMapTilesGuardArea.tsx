"use client"

import { TJoinMap } from "@/methods/functions/map/joinMap"
import { useMapTilesArea } from "@/methods/hooks/world/composite/useMapTilesArea"
import { mapTilesGuardAreaSetAtom } from "@/store/atoms"
import { useAtom } from "jotai"

export type TMapTilesGuardAreaSet = Set<string>

export function useActionMapTilesGuardArea() {
  const { calculateAreaFromPoint } = useMapTilesArea()
  const [mapTilesGuardAreaSet, setMapTilesGuardAreaSet] = useAtom(mapTilesGuardAreaSetAtom)

  function selectMapTilesGuardArea(startingPoint: TJoinMap | undefined, clickedTile: TJoinMap | undefined) {
    if (startingPoint && clickedTile) {
      const guardArea = calculateAreaFromPoint(clickedTile.tiles.x, clickedTile.tiles.y, 1)
      const guardAreaSet = new Set(guardArea.map((tile) => `${tile.tiles.x},${tile.tiles.y}`))
      setMapTilesGuardAreaSet(guardAreaSet)
    }
  }

  return { selectMapTilesGuardArea, mapTilesGuardAreaSet }
}
