"use client"

import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import { playerMovementAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export default function TileLayerPlayerMovement(props: TMapTile) {
  const playerMovement = useAtomValue(playerMovementAtom)

  const layerData = playerMovement[`${props.mapTiles.x},${props.mapTiles.y}`]

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
          fill='red'
          opacity={0.5}
        />
      </svg>
    </>
  )
}
