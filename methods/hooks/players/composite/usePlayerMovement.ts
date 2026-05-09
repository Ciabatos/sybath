"use client"

import { doPlayerMovementAction } from "@/methods/actions/world/doPlayerMovementAction"
import { useModalBottomCenter } from "@/methods/hooks/modals/useModalBottomCenter"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { useMapTilesPathFromPointToPoint } from "@/methods/hooks/world/composite/useMapTilesPathFromPointToPoint"
import { useFetchPlayerPosition, usePlayerPositionState } from "@/methods/hooks/world/core/useFetchPlayerPosition"
import { useMutatePlayerPosition } from "@/methods/hooks/world/core/useMutatePlayerPosition"
import { playerMovementPlannedAtom } from "@/store/atoms"
import { EPanelsBottomCenter } from "@/types/enumeration/EPanelsBottomCenter"
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
  const setPlayerMovementPlanned = useSetPlayerMovementPlanned()
  const playerMovementPlanned = usePlayerMovementPlanned()
  const isMoving = Object.keys(playerMovementPlanned).length > 0
  const { getPathFromPointToPoint } = useMapTilesPathFromPointToPoint()
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()
  useFetchPlayerPosition({ mapId, playerId })
  const playerPosition = usePlayerPositionState()
  const [playerPos] = Object.values(playerPosition)
  const { clickedMapTile } = useMapTileActions()
  const { mutatePlayerPosition } = useMutatePlayerPosition({ mapId, playerId })
  const { openModalBottomCenter } = useModalBottomCenter()
  const { resetModalBottomCenter } = useModalBottomCenter()

  async function selectPlayerPath(params: TPlayerMovementParams) {
    const path = getPathFromPointToPoint(params)

    if (!path) {
      return toast.error(`Cannot move to this tile`)
    }

    setPlayerMovementPlanned(path)
    openModalBottomCenter(EPanelsBottomCenter.MovementPanel)
    return toast.success(`Action selected confirm to proceed`)
  }

  async function selectPlayerPathToClickedTile() {
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
    openModalBottomCenter(EPanelsBottomCenter.MovementPanel)
    return toast.success(`Action selected confirm to proceed`)
  }

  async function moveSelectedPlayerPath() {
    if (!playerMovementPlanned || Object.keys(playerMovementPlanned).length === 0) {
      return toast.error("No path selected")
    }

    const result = await doPlayerMovementAction({ path: playerMovementPlanned, playerId: playerId })

    if (!result?.status) {
      return toast.error(result?.message)
    }

    const lastStep = Object.values(playerMovementPlanned).reduce((max, curr) => (curr.order > max.order ? curr : max))
    mutatePlayerPosition([{ x: lastStep.x, y: lastStep.y }])
    resetPlayerMovementPlanned()
    resetModalBottomCenter()
    return toast.success(result?.message)
  }

  async function selectPlayerPathAndMovePlayer(params: TPlayerMovementParams) {
    const path = getPathFromPointToPoint(params)

    if (!path) {
      return toast.error(`Cannot move to this tile`)
    }

    const result = await doPlayerMovementAction({ path: path, ...params })

    if (!result?.status) {
      return toast.error(result?.message)
    }

    const lastStep = Object.values(path).reduce((max, curr) => (curr.order > max.order ? curr : max))
    mutatePlayerPosition([{ x: lastStep.x, y: lastStep.y }])
    resetPlayerMovementPlanned()
    resetModalBottomCenter()
    return toast.success(result?.message)
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

    if (!path) {
      return toast.error(`Cannot move to this tile`)
    }

    const result = await doPlayerMovementAction({ path: path, ...params })

    if (!result?.status) {
      return toast.error(result?.message)
    }

    const lastStep = Object.values(path).reduce((max, curr) => (curr.order > max.order ? curr : max))
    mutatePlayerPosition([{ x: lastStep.x, y: lastStep.y }])
    resetPlayerMovementPlanned()
    resetModalBottomCenter()
    return toast.success(result?.message)
  }

  function resetPlayerMovementPlanned() {
    setPlayerMovementPlanned({})
  }

  function closeMovementPanel() {
    resetPlayerMovementPlanned()
    resetModalBottomCenter()
  }

  return {
    isMoving,
    selectPlayerPath,
    selectPlayerPathToClickedTile,
    moveSelectedPlayerPath,
    selectPlayerPathAndMovePlayer,
    selectPlayerPathAndMovePlayerToClickedTile,
    resetPlayerMovementPlanned,
    closeMovementPanel,
  }
}

export function usePlayerMovementPlanned() {
  return useAtomValue(playerMovementPlannedAtom)
}

export function useSetPlayerMovementPlanned() {
  return useSetAtom(playerMovementPlannedAtom)
}
