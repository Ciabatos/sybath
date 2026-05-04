"use client"

import TileLayerPlayerMovementPlanned from "@/components/map/layers/mapTileLayers/layers/TileLayerPlayerMovementPlanned"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"

export default function MapTileLayerHandling(props: TMapTile) {
  return (
    <>
      <TileLayerPlayerMovementPlanned {...props} />
    </>
  )
}
