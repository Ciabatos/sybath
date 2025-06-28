"use client"

import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useMapTilesActionStatus } from "@/methods/hooks/mapTiles/core/useMapTilesActionStatus"
import { clickedTileAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"

export function useMapTilesManipulation() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const setClickedTile = useSetAtom(clickedTileAtom)
  const { actualMapTilesActionStatus, newMapTilesActionStatus, resetMapTilesActionStatus } = useMapTilesActionStatus()

  function setCoordinatesOnClick(tile: TJoinedMapTile) {
    setClickedTile(tile)
  }

  function handleClickOnMapTile(tile: TJoinedMapTile) {
    if (actualMapTilesActionStatus.MovementAction || actualMapTilesActionStatus.GuardAreaAction || actualMapTilesActionStatus.UseAbilityAction) {
      setCoordinatesOnClick(tile)
    } else if (tile.cities?.name) {
      showCityActionList()
      setCoordinatesOnClick(tile)
    } else if (tile.districts?.name) {
      showDistrictActionList()
      setCoordinatesOnClick(tile)
    } else if (tile.playerVisibleMapData?.player_id) {
      showPlayerActionList()
      setCoordinatesOnClick(tile)
    } else if (!tile.cities?.name && !tile.districts?.name && !tile.playerVisibleMapData?.player_id && actualMapTilesActionStatus.Inactive) {
      showEmptyTileActionList()
      setCoordinatesOnClick(tile)
    } else {
      setCoordinatesOnClick(tile)
      resetMapTilesActionStatus()
    }
  }

  function showPlayerActionList() {
    //prettier-ignore
    if (actualMapTilesActionStatus.Inactive) {
	  newMapTilesActionStatus.PlayerActionList()
	}
  }

  function showCityActionList() {
    //prettier-ignore
    if (actualMapTilesActionStatus.Inactive) {
	  newMapTilesActionStatus.CityActionList()
	}
  }

  function showDistrictActionList() {
    //prettier-ignore
    if (actualMapTilesActionStatus.Inactive) {
	  newMapTilesActionStatus.DistrictActionList()
	}
  }

  function showEmptyTileActionList() {
    //prettier-ignore
    if (actualMapTilesActionStatus.Inactive) {
	  newMapTilesActionStatus.EmptyTileActionList()
	}
  }

  return { clickedTile, handleClickOnMapTile }
}
