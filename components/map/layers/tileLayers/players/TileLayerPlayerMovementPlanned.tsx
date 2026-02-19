"use client"

import { TMapTile } from "@/methods/hooks/world/composite/useMapHandlingData"
import { playerMovementPlannedAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export default function TileLayerPlayerMovementPlanned(props: TMapTile) {
  const playerMovementPlanned = useAtomValue(playerMovementPlannedAtom)

  const layerData = playerMovementPlanned[`${props.mapTiles.x},${props.mapTiles.y}`]

  if (!layerData) {
    return null
  }

  return (
    <>
      {/* <p>{layerData.moveCost}</p> */}
      <svg
        fill='none'
        xmlns='http://www.w3.org/2000/svg'
        style={{ position: "absolute", top: 0, left: 0, width: "100%", height: "100%" }}
      >
        <rect
          width='100%'
          height='100%'
          fill='blue'
          opacity={0.5}
        />
      </svg>
    </>
  )
}
