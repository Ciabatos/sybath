"use client"

import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { usePlayerPositionMapTile } from "@/methods/hooks/mapTiles/composite/usePlayerPositionMapTile"
import { useMapTilesActionStatus } from "@/methods/hooks/mapTiles/core/useMapTilesActionStatus"
import { clickedTileAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"

export function useMapTileActions() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const setClickedTile = useSetAtom(clickedTileAtom)
  const { actualMapTilesActionStatus, newMapTilesActionStatus, resetMapTilesActionStatus } = useMapTilesActionStatus()

  const { playerMapTile } = usePlayerPositionMapTile()

  function handleClickOnMapTile(tile: TJoinedMapTile) {
    if (actualMapTilesActionStatus.MovementAction || actualMapTilesActionStatus.GuardAreaAction || actualMapTilesActionStatus.UseAbilityAction) {
      setClickedTile(tile)
    } else if (tile.cities?.name) {
      showCityActionList()
      setClickedTile(tile)
    } else if (tile.districts?.name) {
      showDistrictActionList()
      setClickedTile(tile)
    } else if (!tile.cities?.name && !tile.districts?.name && actualMapTilesActionStatus.Inactive) {
      showEmptyTileActionList()
      setClickedTile(tile)
    } else {
      setClickedTile(tile)
      resetMapTilesActionStatus()
    }
  }

  function handleOpenPlayerActionList() {
    if (actualMapTilesActionStatus.Inactive && playerMapTile) {
      setClickedTile(playerMapTile)
      showPlayerActionList()
    }
  }

  function handleClosePlayerActionList() {
    if (actualMapTilesActionStatus.PlayerActionList) {
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

  return { clickedTile, handleClickOnMapTile, handleOpenPlayerActionList, handleClosePlayerActionList }
}
