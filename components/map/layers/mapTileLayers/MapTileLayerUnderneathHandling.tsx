"use client"

import TileLayerPlayerMovementPlanned from "@/components/map/layers/mapTileLayers/layers/TileLayerPlayerMovementPlanned"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"

/**
 * Warstwy renderowane POD warstwami szczegółowymi kafelka.
 *
 * Nazwa jest tu celowa: obok istnieje `MapTileLayers`, które składa liczniki
 * i ikony zasobów/heroes. Oba komponenty trafiają do tego samego `.layers`
 * kafelka, więc bez „pod" nie wiadomo, który renderuje się pierwszy.
 *
 * Tu: plan ruchu. Tam: liczniki i ikony.
 */
export default function MapTileLayerUnderneathHandling(props: TMapTile) {
  return (
    <>
      <TileLayerPlayerMovementPlanned {...props} />
    </>
  )
}