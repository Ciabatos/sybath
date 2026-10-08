import MapTile from "@/components/map/MapTile"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import { ReactNode } from "react"

type TProps = {
  mapTiles: TMapTile[]
  /** Warstwa dodawana na wierzchu kafelka (zasoby, itd.). */
  renderLayers?: (tile: TMapTile) => ReactNode
}

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