"use client"

import MovementTaskInProcessLayer from "@/components/map/layers/actionTaskInProcessLayer/MovementTaskInProcessLayer"
import { TJoinMap } from "@/methods/functions/deprecated/joinMap3"
import { useFetchActionTaskInProcess } from "@/methods/hooks/tasks/core/useFetchActionTaskInProcess"

interface Props {
  tile: TJoinMap
}

export default function HandlingActionTaskInProcess({ tile }: Props) {
  const { actionTaskInProcess } = useFetchActionTaskInProcess()

  const movementActionTask = actionTaskInProcess?.movementInProcess.find(
    (pathTile) => pathTile.method_parameters.x === tile.tiles.x && pathTile.method_parameters.y === tile.tiles.y,
  )

  if (!movementActionTask) {
    return null
  }

  return <MovementTaskInProcessLayer movementActionTask={movementActionTask} />
}
