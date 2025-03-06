import { useAStar } from "@/methods/hooks/useAStar"
import type { TClickedTile } from "@/methods/hooks/useClickTile"
import { clickedTileAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

//zmiana statusu po kliknieciu button Movment
//startowa pozycja 1 klikniecie
//koncowa pozycja 2 klikniecie
//policz astar
//pokoloruj path

export function usePlayerActionMapTilesMovement() {
  const { runAStar } = useAStar()
  const endingPoint = useAtomValue(clickedTileAtom)

  // const [highlightedTile, setHighlightedTile] = useState<{ x: number; y: number } | null>(null)
  // console.log(endingPoint)

  function playerActionMapTilesMovement(startingPoint: TClickedTile) {
    if (!startingPoint || !endingPoint) return
    const movmentPath = runAStar(startingPoint!.x, startingPoint!.y, endingPoint!.x, endingPoint!.y, 0)
    console.log(movmentPath, "movmentPath")
    console.log(startingPoint, "startingPoint")
    console.log(endingPoint, "endingPoint")
  }
  return { playerActionMapTilesMovement }
}
