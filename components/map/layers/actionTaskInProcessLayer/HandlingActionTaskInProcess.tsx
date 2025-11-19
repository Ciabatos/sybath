"use client"

import MovementTaskInProcessLayer from "@/components/map/layers/actionTaskInProcessLayer/MovementTaskInProcessLayer"
import { TJoinMap } from "@/methods/functions/map/joinMap"
import { useFetchActionTaskInProcess } from "@/methods/hooks/tasks/core/useFetchActionTaskInProcess"

interface Props {
  tile: TJoinMap
}

export default function HandlingActionTaskInProcess({ tile }: Props) {
  const { actionTaskInProcess } = useFetchActionTaskInProcess()

  const movementActionTask = actionTaskInProcess?.movementInProcess.find((pathTile) => pathTile.method_parameters.x === tile.mapTile.x && pathTile.method_parameters.y === tile.mapTile.y)

  if (!movementActionTask) {
    return null
  }

  return <MovementTaskInProcessLayer movementActionTask={movementActionTask} />
}
