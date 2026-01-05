"use client"

import { playerMovementAction, TPlayerMovementActionParams } from "@/methods/actions/world/playerMovementAction"
import { useMapTilesPathFromPointToPoint } from "@/methods/hooks/world/composite/useMapTilesPathFromPointToPoint"
import { playerMapTilesMovementPathAtom } from "@/store/atoms"
import { useAtom } from "jotai"

export type TSelectPlayerPathParams = {
  startX: number
  startY: number
  endX: number
  endY: number
  mapId: number
}

export type TSelectAndMovePlayerParams = {
  startX: number
  startY: number
  endX: number
  endY: number
  mapId: number
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

  function doPlayerMovementAction(params: TPlayerMovementActionParams) {
    if (params) {
      playerMovementAction(params)
    }
  }

  return { playerMapTilesMovementPath, selectPlayerPath, selectPlayerPathAndMovePlayer }
}
