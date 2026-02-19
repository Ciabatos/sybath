"use client"

import TileLayerPlayerMovement from "@/components/map/layers/tileLayers/players/TileLayerPlayerMovement"
import TileLayerPlayerMovementPlanned from "@/components/map/layers/tileLayers/players/TileLayerPlayerMovementPlanned"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandlingData"

export default function TileLayersHandling(props: TMapTile) {
  return (
    <>
      <TileLayerPlayerMovement {...props} />
      <TileLayerPlayerMovementPlanned {...props} />
    </>
  )
}
