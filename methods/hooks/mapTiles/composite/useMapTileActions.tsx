"use client"

import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useGetJoinedMapTileByKey } from "@/methods/hooks/mapTiles/core/useGetMapTileByCoordinates"
import { useMapTilesActionStatus } from "@/methods/hooks/mapTiles/core/useMapTilesActionStatus"
import { clickedTileAtom } from "@/store/atoms"
import { useAtom } from "jotai"

export type TClickedTile = { x: number; y: number } | undefined

export function useMapTileActions() {
  const [clickedTile, setClickedTile] = useAtom(clickedTileAtom)
  const { actualMapTilesActionStatus, newMapTilesActionStatus, resetMapTilesActionStatus } = useMapTilesActionStatus()
  const { getTileByCoordinates } = useGetJoinedMapTileByKey()

  function handleClickOnMapTile(tile: TJoinedMapTile) {
    if (actualMapTilesActionStatus.MovementAction || actualMapTilesActionStatus.GuardAreaAction || actualMapTilesActionStatus.UseAbilityAction) {
      setClickedTile({ x: tile.mapTile.x, y: tile.mapTile.y })
    } else if (tile.cities?.name) {
      showCityActionList()
      setClickedTile({ x: tile.mapTile.x, y: tile.mapTile.y })
    } else if (tile.districts?.name) {
      showDistrictActionList()
      setClickedTile({ x: tile.mapTile.x, y: tile.mapTile.y })
    } else if (!tile.cities?.name && !tile.districts?.name && actualMapTilesActionStatus.Inactive) {
      showEmptyTileActionList()
      setClickedTile({ x: tile.mapTile.x, y: tile.mapTile.y })
    } else {
      setClickedTile({ x: tile.mapTile.x, y: tile.mapTile.y })
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
