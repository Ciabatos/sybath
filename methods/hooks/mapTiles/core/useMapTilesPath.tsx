"use client"

import { pathFromPointToPoint } from "@/methods/functions/pathFromPointToPoint"
import { joinedMapTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useMapTilesPath() {
  const mapTiles = useAtomValue(joinedMapTilesAtom)

  function calculatePath(startX: number, startY: number, endX: number, endY: number, objectProperties: unknown) {
    return pathFromPointToPoint(startX, startY, endX, endY, objectProperties, mapTiles)
  }

  return { pathFromPointToPoint: calculatePath }
}
