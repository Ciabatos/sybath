"use client"

import { pathFromPointToPoint } from "@/methods/functions/map/pathFromPointToPoint"
import { joinedMapAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useMapTilesPath() {
  const joinedMap = useAtomValue(joinedMapAtom)

  function calculatePath(startX: number, startY: number, endX: number, endY: number, objectProperties: unknown) {
    return pathFromPointToPoint(startX, startY, endX, endY, objectProperties, joinedMap)
  }

  return { pathFromPointToPoint: calculatePath }
}
