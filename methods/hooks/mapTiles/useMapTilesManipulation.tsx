"use client"

import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { clickedTileAtom, mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtom, useSetAtom } from "jotai"

export function useMapTileManipulation() {
  const setClickedTile = useSetAtom(clickedTileAtom)
  const [statusModalBottomCenterBar, setStatusModalBottomCenterBar] = useAtom(mapTilesActionStatusAtom)

  function setCoordinatesOnClick(tile: TJoinedMapTile) {
    setClickedTile(tile)
  }

  function handleClickOnMapTile(tile: TJoinedMapTile) {
    if (
      statusModalBottomCenterBar === EMapTilesActionStatus.MovementAction ||
      statusModalBottomCenterBar === EMapTilesActionStatus.GuardAreaAction ||
      statusModalBottomCenterBar === EMapTilesActionStatus.UseAbilityAction
    ) {
      setCoordinatesOnClick(tile)
    } else if (tile.cities?.name) {
      showCityActionList(tile)
    } else if (tile.districts?.name) {
      showDistrictActionList(tile)
    } else if (tile.playerVisibleMapData?.player_id) {
      showPlayerActionList(tile)
    } else {
      setCoordinatesOnClick(tile)
      setStatusModalBottomCenterBar(EMapTilesActionStatus.Inactive)
    }
  }

  function showPlayerActionList(tile: TJoinedMapTile) {
    setCoordinatesOnClick(tile)
    //prettier-ignore
    if (statusModalBottomCenterBar === EMapTilesActionStatus.Inactive) {
	  setStatusModalBottomCenterBar(EMapTilesActionStatus.PlayerActionList)
	}
  }

  function showCityActionList(tile: TJoinedMapTile) {
    setCoordinatesOnClick(tile)
    //prettier-ignore
    if (statusModalBottomCenterBar === EMapTilesActionStatus.Inactive) {
	  setStatusModalBottomCenterBar(EMapTilesActionStatus.CityActionList)
	}
  }

  function showDistrictActionList(tile: TJoinedMapTile) {
    setCoordinatesOnClick(tile)
    //prettier-ignore
    if (statusModalBottomCenterBar === EMapTilesActionStatus.Inactive) {
	  setStatusModalBottomCenterBar(EMapTilesActionStatus.DistrictActionList)
	}
  }
  return { handleClickOnMapTile }
}
