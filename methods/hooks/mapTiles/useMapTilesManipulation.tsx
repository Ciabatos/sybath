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
    if (
      statusModalBottomCenterBar === EMapTilesActionStatus.MovementAction ||
      statusModalBottomCenterBar === EMapTilesActionStatus.GuardAreaAction ||
      statusModalBottomCenterBar === EMapTilesActionStatus.UseAbilityAction
    ) {
      setCoordinatesOnClick(tile.mapTile.x, tile.mapTile.y)
    } else if (tile.cities?.name) {
      showPlayerActionList(tile)
    } else if (tile.districts?.name) {
      showPlayerActionList(tile)
    } else if (tile.playerVisibleMapData?.player_id) {
      showPlayerActionList(tile)
    } else {
      setCoordinatesOnClick(tile.mapTile.x, tile.mapTile.y)
      setStatusModalBottomCenterBar(EMapTilesActionStatus.Inactive)
    }
  }

  function showPlayerActionList(tile: TJoinedMapTile) {
    setCoordinatesOnClick(tile.mapTile.x, tile.mapTile.y)
    //prettier-ignore
    if (statusModalBottomCenterBar === EMapTilesActionStatus.Inactive) {
	  setStatusModalBottomCenterBar(EMapTilesActionStatus.PlayerActionList)
	}
  }

  return { handleClickOnMapTile }
}
