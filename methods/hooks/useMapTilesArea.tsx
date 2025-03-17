"use client"

import { TjoinedMapTile } from "@/methods/functions/joinMapTiles"
import { joinedMapTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useMapTilesArea() {
  const mapTiles = useAtomValue(joinedMapTilesAtom)

  function areaFromPoint(startX: number, startY: number, objectProperties: number): TjoinedMapTile[] {
    if (!startX || !startY) {
      return []
    }

    const AreaXY: { x: number; y: number }[] = []

    for (let x = startX - objectProperties; x <= startX + objectProperties; x++) {
      for (let y = startY - objectProperties; y <= startY + objectProperties; y++) {
        const dist = Math.abs(startX - x) + Math.abs(startY - y)
        if (dist <= objectProperties || dist <= objectProperties * 2) {
          AreaXY.push({ x, y })
        }
      }
    }

    const filteredMapTiles = AreaXY.flatMap(({ x, y }) => {
      const key = `${x},${y}`
      const tile = mapTiles[key]
      return tile ? [tile] : []
    })

    return filteredMapTiles
  }

  return { areaFromPoint }
}
