'use client'

import { playerMovementAction } from '@/methods/actions/world/playerMovementAction'
import { TJoinMap } from '@/methods/functions/map/joinMap'
import { pathFromPointToPoint } from '@/methods/functions/map/pathFromPointToPoint'
import { joinedMapAtom, mapTilesMovementPathSetAtom } from '@/store/atoms'
import { useAtom, useAtomValue } from 'jotai'

export type TMapTilesMovementPathSet = Set<string>

export function useMapTilesMovement() {
  const [mapTilesMovementPathSet, setMapTilesMovementPathSet] = useAtom(mapTilesMovementPathSetAtom)
  const joinedMap = useAtomValue(joinedMapAtom)

  function selectMapTilesMovementPath(startingPoint: TJoinMap | undefined, clickedTile: TJoinMap | undefined) {
    if (startingPoint && clickedTile) {
      const movementPath = pathFromPointToPoint({
        startX: startingPoint.tiles.x,
        startY: startingPoint.tiles.y,
        endX: clickedTile.tiles.x,
        endY: clickedTile.tiles.y,
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
