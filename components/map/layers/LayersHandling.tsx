"use client"

import HandlingAction from "@/components/map/layers/actionLayer/HandlingActionLayer"
import { TJoinMap } from "@/methods/functions/map/joinMap"

interface Props {
  tile: TJoinMap
}

export default function LayersHandling({ tile }: Props) {
  return (
    <>
      <HandlingAction tile={tile} />
      {/* <HandlingActionTaskInProcess tile={tile} /> */}
    </>
  )
}
