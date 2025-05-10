"use client"

import { clickedTileAtom, mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtom } from "jotai"

export type TTileCoordinates = {
  x: number
  y: number
}

export function useMapTileManipulation() {
  const [clickedTile, setClickedTile] = useAtom(clickedTileAtom)
  const [statusModalBottomCenterBar, setStatusModalBottomCenterBar] = useAtom(mapTilesActionStatusAtom)

  function setCoordinatesOnClick(x: number, y: number) {
    setClickedTile({ x, y })
  }

  function handleClickOnMapTile(x: number, y: number) {
    setCoordinatesOnClick(x, y)

    //prettier-ignore
    if (statusModalBottomCenterBar === EMapTilesActionStatus.Inactive
	 || statusModalBottomCenterBar === EMapTilesActionStatus.TileActionList) {
	  setStatusModalBottomCenterBar(EMapTilesActionStatus.TileActionList)
	}
  }

  return { clickedTile, setCoordinatesOnClick, handleClickOnMapTile }
}
