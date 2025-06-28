"use client"

import MovementTaskInProcessLayer from "@/components/map/layers/actionTaskInProcessLayer/MovementTaskInProcessLayer"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useFetchActionTaskInProcess } from "@/methods/hooks/tasks/core/useFetchActionTaskInProcess"

interface Props {
  tile: TJoinedMapTile
}

export default function HandlingActionTaskInProcess({ tile }: Props) {
  const { actionTaskInProcess } = useFetchActionTaskInProcess()

  const movementActionTask = actionTaskInProcess?.movementInProcess.find((pathTile) => pathTile.method_parameters.x === tile.mapTile.x && pathTile.method_parameters.y === tile.mapTile.y)

  if (!movementActionTask) {
    return null
  }

  return <MovementTaskInProcessLayer movementActionTask={movementActionTask} />
}
