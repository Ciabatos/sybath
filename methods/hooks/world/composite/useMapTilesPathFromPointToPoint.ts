"use client"

import { pathFromPointToPoint, TPathFromPointToPoint } from "@/methods/functions/map/pathFromPointToPoint"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { joinedMapAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

type TGetPathFromPointToPointParams = {
  startX: number
  startY: number
  endX: number
  endY: number
}

export type TMapTilesMovementPathRecordByXY = Record<string, TPathFromPointToPoint>

export function useMapTilesPathFromPointToPoint() {
  const joinedMap = useAtomValue(joinedMapAtom)

  function getPathFromPointToPoint(params: TGetPathFromPointToPointParams) {
    const movementPath = pathFromPointToPoint({
      startX: params.startX,
      startY: params.startY,
      endX: params.endX,
      endY: params.endY,
      mapTiles: joinedMap,
    })
    const movementPathRecordByXY = arrayToObjectKey(["x", "y"], movementPath) as TMapTilesMovementPathRecordByXY
    return movementPathRecordByXY
  }

  return {
    getPathFromPointToPoint,
  }
}
