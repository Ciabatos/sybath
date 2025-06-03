"use client"

import MapTileLayerHandlingAction from "@/components/map/MapTileLayerHandlingAction"
import MapTileLayerHandlingActionTaskInProcess from "@/components/map/MapTileLayerHandlingActionTaskInProcess"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"

interface Props {
  tile: TJoinedMapTile
}

export default function MapTileLayerHandling({ tile }: Props) {
  return (
    <>
      <MapTileLayerHandlingAction tile={tile} />
      <MapTileLayerHandlingActionTaskInProcess tile={tile} />
    </>
  )
}
