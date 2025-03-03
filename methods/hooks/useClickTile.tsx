import { useSetAtom } from "jotai"
import { clickedTileAtom } from "@/store/atoms"

export function useClickMapTile() {
  const setClickedTile = useSetAtom(clickedTileAtom)

  function setCoordinatesOnClick(x: number, y: number) {
    setClickedTile({ x, y })
  }

  return { setCoordinatesOnClick }
}
