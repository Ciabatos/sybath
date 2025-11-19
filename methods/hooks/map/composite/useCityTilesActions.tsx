"use client"

import { useGetJoineCityTileByCoordinates } from "@/methods/hooks/cityTiles/core/useGetCityTilesByCoordinates"
import { clickedCityTileAtom } from "@/store/atoms"
import { useAtom } from "jotai"

export type TClickeCityTile = { x: number; y: number }

export function useCityTilesActions() {
  const [clickedCityTile, setClickedCityTile] = useAtom(clickedCityTileAtom)
  const { getCityTileByCoordinates } = useGetJoineCityTileByCoordinates()

  function getClickedCityTile() {
    if (clickedCityTile) {
      return getCityTileByCoordinates(clickedCityTile.x, clickedCityTile.y)
    }
  }

  return { getClickedCityTile, setClickedCityTile }
}
