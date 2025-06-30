"use client"

import { clickedCityTileAtom } from "@/store/atoms"
import { useAtom } from "jotai"

export function useCityTilesManipulation() {
  const [clickedCityTile, setClickedCityTile] = useAtom(clickedCityTileAtom)

  return { clickedCityTile, setClickedCityTile }
}
