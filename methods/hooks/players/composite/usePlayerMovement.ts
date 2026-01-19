"use client"

import { doPlayerMovementAction } from "@/methods/actions/world/doPlayerMovementAction"
import { useMapTilesPathFromPointToPoint } from "@/methods/hooks/world/composite/useMapTilesPathFromPointToPoint"
import { playerMapTilesMovementPathAtom } from "@/store/atoms"
import { useAtom } from "jotai"

export type TSelectPlayerPathParams = {
  playerId: number
  startX: number
  startY: number
  endX: number
  endY: number
}

export type TSelectAndMovePlayerParams = {
  playerId: number
  startX: number
  startY: number
  endX: number
  endY: number
}

export function usePlayerMovement() {
  const { getPathFromPointToPoint } = useMapTilesPathFromPointToPoint()
  const [playerMapTilesMovementPath, setPlayerMapTilesMovementPath] = useAtom(playerMapTilesMovementPathAtom)

  function selectPlayerPath(params: TSelectPlayerPathParams) {
    const path = getPathFromPointToPoint(params)
    setPlayerMapTilesMovementPath(path)
  }

  function selectPlayerPathAndMovePlayer(params: TSelectAndMovePlayerParams) {
    const path = getPathFromPointToPoint(params)
    setPlayerMapTilesMovementPath(path)
    doPlayerMovementAction(params)
  }

  return { playerMapTilesMovementPath, selectPlayerPath, selectPlayerPathAndMovePlayer }
}
