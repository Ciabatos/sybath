"use client"

import { playerMovementAction } from "@/methods/actions/world/playerMovementAction"
import { TJoinMap } from "@/methods/functions/map/joinMap"
import { pathFromPointToPoint } from "@/methods/functions/map/pathFromPointToPoint"
import { joinedMapAtom, mapTilesMovementPathSetAtom } from "@/store/atoms"
import { useAtom, useAtomValue } from "jotai"

type TSelectMapTilesMovementPathParams = {
  startingTile: TJoinMap
  endingTile: TJoinMap
}

export function useMapTilesMovement() {
  const [mapTilesMovementPathSet, setMapTilesMovementPathSet] = useAtom(mapTilesMovementPathSetAtom)
  const joinedMap = useAtomValue(joinedMapAtom)

  function selectMapTilesMovementPath(params: TSelectMapTilesMovementPathParams) {
    if (startingPoint && clickedTile) {
      const movementPath = pathFromPointToPoint({
        startX: params.startingTile.tiles.x,
        startY: params.startingTile.tiles.y,
        endX: params.endingTile.tiles.x,
        endY: params.endingTile.tiles.y,
        mapTiles: joinedMap,
      })
      const movementPathSet = new Set(movementPath.map((tile) => `${tile.tiles.x},${tile.tiles.y}`))
      setMapTilesMovementPathSet(movementPathSet)
    }
  }

  function doPlayerMovementAction(startingPoint: TJoinMap | undefined, clickedTile: TJoinMap | undefined) {
    if (startingPoint && clickedTile) {
      playerMovementAction(startingPoint, clickedTile)
    }
  }

  return {
    selectMapTilesMovementPath,
    mapTilesMovementPathSet,
    doPlayerMovementAction,
  }
}
