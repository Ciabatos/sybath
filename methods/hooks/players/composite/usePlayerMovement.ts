"use client"

import { doPlayerMovementAction } from "@/methods/actions/world/doPlayerMovementAction"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { useMapTilesPathFromPointToPoint } from "@/methods/hooks/world/composite/useMapTilesPathFromPointToPoint"
import { useFetchPlayerMovement } from "@/methods/hooks/world/core/useFetchPlayerMovement"
import { useFetchPlayerPosition } from "@/methods/hooks/world/core/useFetchPlayerPosition"
import { useMutatePlayerMovement } from "@/methods/hooks/world/core/useMutatePlayerMovement"
import { playerMovementPlannedAtom, playerPositionAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { toast } from "sonner"

type TPlayerMovementParams = {
  playerId: number
  startX: number
  startY: number
  endX: number
  endY: number
}

export function usePlayerMovement() {
  const setPlayerMovementPlanned = useSetAtom(playerMovementPlannedAtom)

  const { getPathFromPointToPoint } = useMapTilesPathFromPointToPoint()

  const { playerId } = usePlayerId()
  const { mapId } = useMapId()

  useFetchPlayerPosition({ mapId, playerId })
  const playerPosition = useAtomValue(playerPositionAtom)
  const [playerPos] = Object.values(playerPosition)

  const { clickedTile } = useMapTileActions()

  const { mutatePlayerMovement } = useMutatePlayerMovement({ playerId })

  useFetchPlayerMovement({ playerId })

  function selectPlayerPath(params: TPlayerMovementParams) {
    const path = getPathFromPointToPoint(params)
    setPlayerMovementPlanned(path)

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
    setPlayerMovementPlanned(path)

    return toast.success(`Path selected confirm to move`)
  }

  function selectPlayerPathAndMovePlayer(params: TPlayerMovementParams) {
    const path = getPathFromPointToPoint(params)
    resetPlayerMovementPlanned()
    doPlayerMovementAction({ path: path, ...params })

    mutatePlayerMovement(Object.values(path))

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
    resetPlayerMovementPlanned()
    doPlayerMovementAction({ path: path, ...params })

    mutatePlayerMovement(Object.values(path))
    return toast.success(`You are moving to destination`)
  }

  function resetPlayerMovementPlanned() {
    setPlayerMovementPlanned({})
  }

  return {
    selectPlayerPath,
    selectPlayerPathToClickedTile,
    selectPlayerPathAndMovePlayer,
    selectPlayerPathAndMovePlayerToClickedTile,
    resetPlayerMovementPlanned,
  }
}
