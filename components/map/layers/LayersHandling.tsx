"use client"

import HandlingActionLayer from "@/components/map/layers/actionLayer/HandlingActionLayer"
import { TJoinMap } from "@/methods/functions/map/joinMap"

interface Props {
  tile: TJoinMap
}

export default function LayersHandling({ tile }: Props) {
  return (
    <>
      <HandlingActionLayer tile={tile} />
      {/* <HandlingActionTaskInProcess tile={tile} /> */}
    </>
  )
}
