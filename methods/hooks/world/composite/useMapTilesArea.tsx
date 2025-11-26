"use client"

import { areaFromPoint } from "@/methods/functions/map/areaFromPoint"
import { joinedMapAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useMapTilesArea() {
  const joinedMap = useAtomValue(joinedMapAtom)

  function calculateArea(startX: number, startY: number, objectProperties: number) {
    return areaFromPoint(startX, startY, objectProperties, joinedMap)
  }

  return { areaFromPoint: calculateArea }
}
