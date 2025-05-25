"use client"

import { TJoinedCityTiles } from "@/methods/functions/joinCityTiles"
import { cityTilesActionStatusAtom, clickedCityTileAtom } from "@/store/atoms"
import { ECityTilesActionStatus } from "@/types/enumeration/CityTilesActionStatusEnum"
import { useAtom, useSetAtom } from "jotai"

export function useCityTilesManipulation() {
  const setClickedCityTile = useSetAtom(clickedCityTileAtom)
  const [cityTilesActionStatus, setCityTilesActionStatus] = useAtom(cityTilesActionStatusAtom)

  function setCoordinatesOnClick(tile: TJoinedCityTiles) {
    setClickedCityTile(tile)
  }

  function handleClickOnCityTile(tile: TJoinedCityTiles) {
    if (cityTilesActionStatus === ECityTilesActionStatus.Inactive) {
      showBuildingActionList(tile)
    }
  }

  function showBuildingActionList(tile: TJoinedCityTiles) {
    setCoordinatesOnClick(tile)
    //prettier-ignore
    if (cityTilesActionStatus === ECityTilesActionStatus.Inactive) {
	  setCityTilesActionStatus(ECityTilesActionStatus.BuildingActionList)
	}
  }

  return { handleClickOnCityTile }
}
