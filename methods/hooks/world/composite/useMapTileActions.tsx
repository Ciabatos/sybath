"use client"

import { TJoinMap } from "@/methods/functions/map/joinMap"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { clickedTileAtom } from "@/store/atoms"
import { useAtom } from "jotai"

export function useMapTileActions() {
  const [clickedTile, setClickedTile] = useAtom(clickedTileAtom)
  const { setModalTopCenter } = useModalTopCenter

  function handleClickOnMapTile(params: TJoinMap) {
    if (
      actualMapTilesActionStatus.MovementAction ||
      actualMapTilesActionStatus.GuardAreaAction ||
      actualMapTilesActionStatus.UseAbilityAction
    ) {
      setClickedTile(params)
    } else if (params.cities?.name) {
      showCityActionList()
      setClickedTile(params)
    } else if (params.districts?.name) {
      showDistrictActionList()
      setClickedTile(params)
    } else if (!params.cities?.name && !params.districts?.name && actualMapTilesActionStatus.Inactive) {
      showEmptyTileActionList()
      setClickedTile(params)
    } else {
      setClickedTile(params)
      resetMapTilesActionStatus()
    }
  }

  function handleOpenPlayerActionList() {
    if (actualMapTilesActionStatus.Inactive) {
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
