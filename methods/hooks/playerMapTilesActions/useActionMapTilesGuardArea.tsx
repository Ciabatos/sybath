"use client"

import { useMapTilesArea } from "@/methods/hooks/mapTiles/useMapTilesArea"
import { useMapTilesPath } from "@/methods/hooks/mapTiles/useMapTilesPath"
import { clickedTileAtom, mapTilesActionStatusAtom, mapTilesGuardAreaAtom, mapTilesMovmentPathAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useState } from "react"

export function useActionMapTilesGuardArea() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const [startingPoint] = useState(clickedTile)
  const { pathFromPointToPoint } = useMapTilesPath()
  const setMapTilesMovmentPath = useSetAtom(mapTilesMovmentPathAtom)
  const { areaFromPoint } = useMapTilesArea()
  const setMapTilesGuardArea = useSetAtom(mapTilesGuardAreaAtom)
  const setOpenModalBottomCenterBar = useSetAtom(mapTilesActionStatusAtom)

  useEffect(() => {
    if (startingPoint && clickedTile) {
      const movmentPath = pathFromPointToPoint(startingPoint.mapTile.x, startingPoint.mapTile.y, clickedTile.mapTile.x, clickedTile.mapTile.y, 0)
      setMapTilesMovmentPath(movmentPath)
      const guardArea = areaFromPoint(clickedTile.mapTile.x, clickedTile.mapTile.y, 1)
      setMapTilesGuardArea(guardArea)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  const handleButtonGuardArea = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
  }

  const handleButtonCancel = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
  }
  return {
    endingPoint: clickedTile,
    handleButtonGuardArea,
    handleButtonCancel,
  }
}
