"use client"

import { doPlayerMovementAction } from "@/methods/actions/world/doPlayerMovementAction"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { useMapTilesPathFromPointToPoint } from "@/methods/hooks/world/composite/useMapTilesPathFromPointToPoint"
import { useFetchPlayerPosition } from "@/methods/hooks/world/core/useFetchPlayerPosition"
import { playerMapTilesMovementPathAtom, playerPositionAtom } from "@/store/atoms"
import { useAtom, useAtomValue } from "jotai"
import { toast } from "sonner"

type TPlayerMovementParams = {
  playerId: number
  startX: number
  startY: number
  endX: number
  endY: number
}

export function usePlayerMovement() {
  const { getPathFromPointToPoint } = useMapTilesPathFromPointToPoint()
  const [playerMapTilesMovementPath, setPlayerMapTilesMovementPath] = useAtom(playerMapTilesMovementPathAtom)

  const { playerId } = usePlayerId()
  const { mapId } = useMapId()

  useFetchPlayerPosition({ mapId, playerId })
  const playerPosition = useAtomValue(playerPositionAtom)
  const [playerPos] = Object.values(playerPosition)

  const { clickedTile } = useMapTileActions()

  function selectPlayerPath(params: TPlayerMovementParams) {
    const path = getPathFromPointToPoint(params)
    setPlayerMapTilesMovementPath(path)

    return toast.success(`Path selected confirm to move`)
  }

  function selectPlayerPathToClickedTile() {
    if (!clickedTile) {
      return toast.error("No tile selected")
    }

    const params = {
      startX: playerPos.x,
      startY: playerPos.y,
      endX: clickedTile.mapTiles.x,
      endY: clickedTile.mapTiles.y,
    }

    const path = getPathFromPointToPoint(params)
    setPlayerMapTilesMovementPath(path)

    return toast.success(`Path selected confirm to move`)
  }

  function selectPlayerPathAndMovePlayer(params: TPlayerMovementParams) {
    const path = getPathFromPointToPoint(params)
    setPlayerMapTilesMovementPath(path)
    doPlayerMovementAction(params)

    return toast.success(`You are moving to destination`)
  }

  function selectPlayerPathAndMovePlayerToClickedTile() {
    if (!clickedTile) {
      return toast.error("No tile selected")
    }

    const params = {
      playerId,
      startX: playerPos.x,
      startY: playerPos.y,
      endX: clickedTile.mapTiles.x,
      endY: clickedTile.mapTiles.y,
    }

    const path = getPathFromPointToPoint(params)
    setPlayerMapTilesMovementPath(path)
    doPlayerMovementAction(params)

    return toast.success(`You are moving to destination`)
  }

  return {
    playerMapTilesMovementPath,
    selectPlayerPath,
    selectPlayerPathToClickedTile,
    selectPlayerPathAndMovePlayer,
    selectPlayerPathAndMovePlayerToClickedTile,
  }
}
