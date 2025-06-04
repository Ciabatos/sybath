"use client"

import MapTileLayerMovementTaskInProcess from "@/components/map/MapTileLayerMovementTaskInProcess"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useActionTaskInProcess } from "@/methods/hooks/tasks/useActionTaskInProcess"

interface Props {
  tile: TJoinedMapTile
}

export default function MapTileLayerHandlingActionTaskInProcess({ tile }: Props) {
  const { actionTaskInProcess } = useActionTaskInProcess()

  const movementActionTask = actionTaskInProcess?.movmentInProcess.find((pathTile) => pathTile.method_parameters.x === tile.mapTile.x && pathTile.method_parameters.y === tile.mapTile.y)

  if (!movementActionTask) {
    return null
  }

  return <MapTileLayerMovementTaskInProcess movementActionTask={movementActionTask} />
}
