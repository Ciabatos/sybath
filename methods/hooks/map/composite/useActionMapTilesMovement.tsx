"use client"

import { playerMovementAction } from "@/methods/actions/mapTiles/playerMovementAction"
import { TJoinMap } from "@/methods/functions/map/joinMap"
import { useMapTilesPath } from "@/methods/hooks/map/composite/useMapTilesPath"
import { mapTilesMovementPathSetAtom } from "@/store/atoms"
import { useAtom } from "jotai"

export type TMapTilesMovementPathSet = Set<string>

export function useActionMapTilesMovement() {
  const [mapTilesMovementPathSet, setMapTilesMovementPathSet] = useAtom(mapTilesMovementPathSetAtom)
  const { pathFromPointToPoint } = useMapTilesPath()

  function selectMapTilesMovementPath(startingPoint: TJoinMap | undefined, clickedTile: TJoinMap | undefined) {
    if (startingPoint && clickedTile) {
      const movementPath = pathFromPointToPoint(startingPoint.tiles.x, startingPoint.tiles.y, clickedTile.tiles.x, clickedTile.tiles.y, 0)
      const movementPathSet = new Set(movementPath.map((tile) => `${tile.tiles.x},${tile.tiles.y}`))
      setMapTilesMovementPathSet(movementPathSet)
    }
  }

  function doPlayerMovementAction() {
    playerMovementAction(mapTilesMovementPathSet)
  }

  return { selectMapTilesMovementPath, mapTilesMovementPathSet, doPlayerMovementAction }
}
