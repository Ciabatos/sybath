"use client"

import { calculateAreaFromPoint, TCalculateAreaFromPoint } from "@/methods/functions/map/areaFromPoint"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

type TGetAreaFromPointParams = {
  startX: number
  startY: number
  range: number
}

export type TAreaRecordByXY = Record<string, TCalculateAreaFromPoint>

export function useMapTilesArea() {
  function getAreaFromPoint(params: TGetAreaFromPointParams) {
    const area = calculateAreaFromPoint({ startX: params.startX, startY: params.startY, range: params.range })
    const areaRecordByXY = arrayToObjectKey(["x", "y"], area) as TAreaRecordByXY
    return areaRecordByXY
  }

  return { getAreaFromPoint }
}
