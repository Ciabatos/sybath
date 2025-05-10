"use client"

import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { clickedTileAtom, mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtom, useSetAtom } from "jotai"

export type TTileCoordinates = {
  x: number
  y: number
}

export function useMapTileManipulation() {
  const setClickedTile = useSetAtom(clickedTileAtom)
  const [statusModalBottomCenterBar, setStatusModalBottomCenterBar] = useAtom(mapTilesActionStatusAtom)

  function setCoordinatesOnClick(x: number, y: number) {
    setClickedTile({ x, y })
  }

  function handleClickOnMapTile(tile: TJoinedMapTile) {
    setCoordinatesOnClick(tile.mapTile.x, tile.mapTile.y)

    //prettier-ignore
    if (statusModalBottomCenterBar === EMapTilesActionStatus.Inactive
	 || statusModalBottomCenterBar === EMapTilesActionStatus.TileActionList) {
	  setStatusModalBottomCenterBar(EMapTilesActionStatus.TileActionList)
	}
  }

  return { handleClickOnMapTile }
}
