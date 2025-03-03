import { useAtomValue } from "jotai"
import { clickedTileAtom } from "@/store/atoms"
import { useAStar } from "@/methods/hooks/useAStar"
import { useState } from "react"

//zmiana statusu po kliknieciu button Movment
//startowa pozycja 1 klikniecie
//koncowa pozycja 2 klikniecie
//policz astar
//pokoloruj path

export function usePlayerActionMapTilesMovement() {
  const { runAStar } = useAStar()
  const [startingPoint, setStartingPoint] = useState<{ x: number; y: number } | null>({ x: 1, y: 1 })
  const endingPoint = useAtomValue(clickedTileAtom)

  // const [highlightedTile, setHighlightedTile] = useState<{ x: number; y: number } | null>(null)
  // console.log(endingPoint)

  function playerActionMapTilesMovement() {
    if (!startingPoint || !endingPoint) return
    const movmentPath = runAStar(startingPoint!.x, startingPoint!.y, endingPoint!.x, endingPoint!.y, 0)
    console.log(movmentPath, "movmentPath")
    console.log(startingPoint, "startingPoint")
    console.log(endingPoint, "endingPoint")
  }
  return { playerActionMapTilesMovement }
}
