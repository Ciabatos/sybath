"use client"

import { useMapTilesArea } from "@/methods/hooks/world/composite/useMapTilesArea"
import { playerMapTilesGuardAreaAtom } from "@/store/atoms"
import { useAtom } from "jotai"

export type TSelectPlayerGuardAreaParams = {
  startX: number
  startY: number
  range: number
}

export function usePlayerGuardArea() {
  const { getAreaFromPoint } = useMapTilesArea()
  const [playerMapTilesGuardArea, setPlayerMapTilesGuardArea] = useAtom(playerMapTilesGuardAreaAtom)

  function selectPlayerGuardArea(params: TSelectPlayerGuardAreaParams) {
    const area = getAreaFromPoint(params)
    setPlayerMapTilesGuardArea(area)
  }

  return { playerMapTilesGuardArea, selectPlayerGuardArea }
}
