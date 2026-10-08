import MapTile from "@/components/map/MapTile"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import { ReactNode } from "react"

type TProps = {
  mapTiles: TMapTile[]
  /** Warstwa dodawana na wierzchu kafelka — patrz `layers/mapAbove`. */
  renderLayers?: (tile: TMapTile) => ReactNode
}

/**
 * Pętla po kafelkach mapy — zawsze włączona.
 *
 * Nie dodaje niczego od siebie: rozstawia kafelki w siatce `.Tiles` i przekazuje
 * każdemu warstwę z `renderLayers`. Reszta warstw żyje w `layers/mapAbove`
 * (liczniki, ikony) i `layers/mapUnderneath` (plan ruchu).
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