"use client"

import HandlingAction from "@/components/map/layers/actionLayer/HandlingActionLayer"
import HandlingActionTaskInProcess from "@/components/map/layers/actionTaskInProcessLayer/HandlingActionTaskInProcess"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"

interface Props {
  tile: TJoinedMapTile
}

export default function LayersHandling({ tile }: Props) {
  return (
    <>
      <HandlingAction tile={tile} />
      <HandlingActionTaskInProcess tile={tile} />
    </>
  )
}
