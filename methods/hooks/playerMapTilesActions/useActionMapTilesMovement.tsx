"use client"

import { playerMovementAction } from "@/methods/actions/mapTiles/playerMovementAction"
import { useMapTilesPath } from "@/methods/hooks/mapTiles/useMapTilesPath"
import { useActionTaskInProcess } from "@/methods/hooks/tasks/useActionTaskInProcess"
import { clickedTileAtom, mapTilesActionStatusAtom, mapTilesMovementPathAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtom, useAtomValue, useSetAtom } from "jotai"
import { useEffect, useState } from "react"

export function useActionMapTilesMovement() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const [startingPoint] = useState(clickedTile)
  const { pathFromPointToPoint } = useMapTilesPath()
  const [mapTilesMovementPath, setMapTilesMovementPath] = useAtom(mapTilesMovementPathAtom)
  const setOpenModalBottomCenterBar = useSetAtom(mapTilesActionStatusAtom)
  const { mutateActionTaskInProcess } = useActionTaskInProcess()

  useEffect(() => {
    if (startingPoint && clickedTile) {
      const movementPath = pathFromPointToPoint(startingPoint.mapTile.x, startingPoint.mapTile.y, clickedTile.mapTile.x, clickedTile.mapTile.y, 0)
      setMapTilesMovementPath(movementPath)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  const handleButtonMove = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
    mutateActionTaskInProcess(mapTilesMovementPath)
    playerMovementAction(mapTilesMovementPath)
  }

  const handleButtonCancel = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
  }

  return {
    startingPoint,
    endingPoint: clickedTile,
    handleButtonMove,
    handleButtonCancel,
  }
}
