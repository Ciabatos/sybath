"use client"

import { playerMovementAction } from "@/methods/actions/mapTiles/playerMovementAction"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useMapTilesPath } from "@/methods/hooks/mapTiles/core/useMapTilesPath"
import { mapTilesMovementPathAtom, mapTilesMovementPathSetAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"

export function useActionMapTilesMovement() {
  const mapTilesMovementPath = useAtomValue(mapTilesMovementPathAtom)
  const setMapTilesMovementPath = useSetAtom(mapTilesMovementPathAtom)
  const mapTilesMovementPathSet = useAtomValue(mapTilesMovementPathSetAtom)
  const setMapTilesMovementPathSet = useSetAtom(mapTilesMovementPathSetAtom)
  const { pathFromPointToPoint } = useMapTilesPath()

  function selectMapTilesMovementPath(startingPoint: TJoinedMapTile | undefined, clickedTile: TJoinedMapTile | undefined) {
    if (startingPoint && clickedTile) {
      const movementPath = pathFromPointToPoint(startingPoint.mapTile.x, startingPoint.mapTile.y, clickedTile.mapTile.x, clickedTile.mapTile.y, 0)
      setMapTilesMovementPath(movementPath)
      const movementPathSet = new Set(movementPath.map((tile) => `${tile.mapTile.x},${tile.mapTile.y}`))
      setMapTilesMovementPathSet(movementPathSet)
    }
  }

  function doPlayerMovementAction() {
    playerMovementAction(mapTilesMovementPath)
  }

  return { selectMapTilesMovementPath, mapTilesMovementPath, mapTilesMovementPathSet, doPlayerMovementAction }
}
