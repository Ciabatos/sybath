"use client"

import { clickedCityTileAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"

export function useCityTilesManipulation() {
  const clickedCityTile = useAtomValue(clickedCityTileAtom)
  const setClickedCityTile = useSetAtom(clickedCityTileAtom)

  return { clickedCityTile, setClickedCityTile }
}
