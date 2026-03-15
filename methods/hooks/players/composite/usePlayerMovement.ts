"use client"

import { doPlayerMovementAction } from "@/methods/actions/world/doPlayerMovementAction"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { useMapTilesPathFromPointToPoint } from "@/methods/hooks/world/composite/useMapTilesPathFromPointToPoint"
import { useFetchPlayerMovement } from "@/methods/hooks/world/core/useFetchPlayerMovement"
import { useFetchPlayerPosition } from "@/methods/hooks/world/core/useFetchPlayerPosition"
import { useMutatePlayerMovement } from "@/methods/hooks/world/core/useMutatePlayerMovement"
import { playerMovementAtom, playerMovementPlannedAtom, playerPositionAtom } from "@/store/atoms"
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

  const { clickedMapTile } = useMapTileActions()

  const { mutatePlayerMovement } = useMutatePlayerMovement({ playerId })

  useFetchPlayerMovement({ playerId })
  const playerMovement = useAtomValue(playerMovementAtom)

  function selectPlayerPath(params: TPlayerMovementParams) {
    const path = getPathFromPointToPoint(params)

    if (!path) {
      return toast.error(`Cannot move to this tile`)
    }

    setPlayerMovementPlanned(path)

    return toast.success(`Path selected confirm to move`)
  }

  function selectPlayerPathToClickedTile() {
    if (!clickedMapTile) {
      return toast.error("No tile selected")
    }

    const params = {
      startX: playerPos.x,
      startY: playerPos.y,
      endX: clickedMapTile.mapTiles.x,
      endY: clickedMapTile.mapTiles.y,
    }

    const path = getPathFromPointToPoint(params)

    if (!path) {
      return toast.error(`Cannot move to this tile`)
    }

    setPlayerMovementPlanned(path)

    return toast.success(`Path selected confirm to move`)
  }

  async function selectPlayerPathAndMovePlayer(params: TPlayerMovementParams) {
    const path = getPathFromPointToPoint(params)

    if (!path) {
      return toast.error(`Cannot move to this tile`)
    }

    resetPlayerMovementPlanned()
    const result = await doPlayerMovementAction({ path: path, ...params })

    mutatePlayerMovement(Object.values(path))

    if (!result?.status) {
      return toast.error(result?.message)
    }
    return toast.success(`You are moving to destination`)
  }

  async function selectPlayerPathAndMovePlayerToClickedTile() {
    if (!clickedMapTile) {
      return toast.error("No tile selected")
    }

    const params = {
      playerId,
      startX: playerPos.x,
      startY: playerPos.y,
      endX: clickedMapTile.mapTiles.x,
      endY: clickedMapTile.mapTiles.y,
    }

    const path = getPathFromPointToPoint(params)
    resetPlayerMovementPlanned()

    if (!path) {
      return toast.error(`Cannot move to this tile`)
    }

    const result = await doPlayerMovementAction({ path: path, ...params })

    if (!result?.status) {
      return toast.error(result?.message)
    }

    mutatePlayerMovement(Object.values(path))

    return toast.success(`You are moving to destination`)
  }

  function resetPlayerMovementPlanned() {
    setPlayerMovementPlanned({})
  }

  return {
    playerMovement,
    selectPlayerPath,
    selectPlayerPathToClickedTile,
    selectPlayerPathAndMovePlayer,
    selectPlayerPathAndMovePlayerToClickedTile,
    resetPlayerMovementPlanned,
  }
}
