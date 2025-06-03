"use client"

import { playerMovmentAction } from "@/methods/actions/mapTiles/playerMovmentAction"
import { useMapTilesPath } from "@/methods/hooks/mapTiles/useMapTilesPath"
import { useActionTaskInProcess } from "@/methods/hooks/tasks/useActionTaskInProcess"
import { clickedTileAtom, mapTilesActionStatusAtom, mapTilesMovmentPathAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtom, useAtomValue, useSetAtom } from "jotai"
import { useEffect, useState } from "react"

export function useActionMapTilesMovement() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const [startingPoint] = useState(clickedTile)
  const { pathFromPointToPoint } = useMapTilesPath()
  const [mapTilesMovmentPath, setMapTilesMovmentPath] = useAtom(mapTilesMovmentPathAtom)
  const setOpenModalBottomCenterBar = useSetAtom(mapTilesActionStatusAtom)
  const { mutateActionTaskInProcess } = useActionTaskInProcess()

  useEffect(() => {
    if (startingPoint && clickedTile) {
      const movmentPath = pathFromPointToPoint(startingPoint.mapTile.x, startingPoint.mapTile.y, clickedTile.mapTile.x, clickedTile.mapTile.y, 0)
      setMapTilesMovmentPath(movmentPath)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  const handleButtonMove = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
    mutateActionTaskInProcess(mapTilesMovmentPath)
    playerMovmentAction(mapTilesMovmentPath)
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
