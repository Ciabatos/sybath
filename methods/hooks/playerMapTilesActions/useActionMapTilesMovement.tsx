"use client"

import { useMapTilesPath } from "@/methods/hooks/mapTiles/useMapTilesPath"
import { clickedTileAtom, mapTilesActionStatusAtom, mapTilesMovmentPathAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useState } from "react"

export function useActionMapTilesMovement() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const [startingPoint] = useState(clickedTile)
  const { pathFromPointToPoint } = useMapTilesPath()
  const setMapTilesMovmentPath = useSetAtom(mapTilesMovmentPathAtom)
  const setOpenModalBottomCenterBar = useSetAtom(mapTilesActionStatusAtom)

  useEffect(() => {
    if (startingPoint && clickedTile) {
      const movmentPath = pathFromPointToPoint(startingPoint.x, startingPoint.y, clickedTile.x, clickedTile.y, 0)
      setMapTilesMovmentPath(movmentPath)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  const handleButtonMove = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
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
