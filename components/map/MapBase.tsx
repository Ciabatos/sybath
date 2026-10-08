import MapTile from "@/components/map/MapTile"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import { ReactNode } from "react"

type TProps = {
  mapTiles: TMapTile[]
  /** Warstwa rysowana na kafelku — budowana przez `MapHandling`. */
  renderLayers?: (tile: TMapTile) => ReactNode
}

/**
 * Pętla po kafelkach mapy.
 *
 * Nie jest warstwą, tylko ciałem mapy: rozstawia kafelki w siatce `.Tiles` i
 * przekazuje każdemu z nich warstwę z `renderLayers`. Co dokładnie zostanie
 * narysowane na kafelku, rozstrzyga `MapTile`.
 *
 * Jeden wywołujący: `MapHandling`.
 */
export default function MapBase({ mapTiles, renderLayers }: TProps) {
  return (
    <>
      {mapTiles.map((tile) => (
        <MapTile
          key={`${tile.mapTiles.x},${tile.mapTiles.y}`}
          mapTile={tile}
          layers={renderLayers?.(tile)}
        />
      ))}
    </>
  )
}