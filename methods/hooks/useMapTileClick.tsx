"use client"
import { clickedTileAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"

export type TClickedTile = {
  x: number
  y: number
}

export function useMapTileClick() {
  const setClickedTile = useSetAtom(clickedTileAtom)

  function setCoordinatesOnClick(x: number, y: number) {
    setClickedTile({ x, y })
  }

  return { setCoordinatesOnClick }
}
