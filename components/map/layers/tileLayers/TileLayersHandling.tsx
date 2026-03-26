"use client"

import TileLayerPlayerMovementPlanned from "@/components/map/layers/tileLayers/players/TileLayerPlayerMovementPlanned"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"

export default function TileLayersHandling(props: TMapTile) {
  return (
    <>
      <TileLayerPlayerMovementPlanned {...props} />
    </>
  )
}
