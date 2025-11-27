"use client"

import { TJoinMap } from "@/methods/functions/map/joinMap"
import { useGetJoinedMapTileByKey } from "@/methods/hooks/world/composite/useGetMapTileByCoordinates"
import { useModal } from "@/methods/hooks/modals/useModal"
import { clickedTileAtom } from "@/store/atoms"
import { useAtom } from "jotai"

export type TClickedTile = { x: number; y: number } | undefined

export function useMapTileActions() {
  const [clickedTile, setClickedTile] = useAtom(clickedTileAtom)
  const { actualMapTilesActionStatus, newMapTilesActionStatus, resetMapTilesActionStatus } = useModal()
  const { getTileByCoordinates } = useGetJoinedMapTileByKey()

  function handleClickOnMapTile(tile: TJoinMap) {
    if (actualMapTilesActionStatus.MovementAction || actualMapTilesActionStatus.GuardAreaAction || actualMapTilesActionStatus.UseAbilityAction) {
      setClickedTile({ x: tile.tiles.x, y: tile.tiles.y })
    } else if (tile.cities?.name) {
      showCityActionList()
      setClickedTile({ x: tile.tiles.x, y: tile.tiles.y })
    } else if (tile.districts?.name) {
      showDistrictActionList()
      setClickedTile({ x: tile.tiles.x, y: tile.tiles.y })
    } else if (!tile.cities?.name && !tile.districts?.name && actualMapTilesActionStatus.Inactive) {
      showEmptyTileActionList()
      setClickedTile({ x: tile.tiles.x, y: tile.tiles.y })
    } else {
      setClickedTile({ x: tile.tiles.x, y: tile.tiles.y })
      resetMapTilesActionStatus()
    }
  }

  function getClickedMapTile() {
    if (clickedTile) {
      return getTileByCoordinates(clickedTile.x, clickedTile.y)
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

  return { getClickedMapTile, handleClickOnMapTile, handleOpenPlayerActionList, handleClosePlayerActionList }
}
