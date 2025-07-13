"use client"

import { areaFromPoint } from "@/methods/functions/areaFromPoint"
import { joinedMapTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useMapTilesArea() {
  const mapTiles = useAtomValue(joinedMapTilesAtom)

  function calculateArea(startX: number, startY: number, objectProperties: number) {
    return areaFromPoint(startX, startY, objectProperties, mapTiles)
  }

  return { areaFromPoint: calculateArea }
}
