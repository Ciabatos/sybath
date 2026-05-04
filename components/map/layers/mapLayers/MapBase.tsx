import MapTile from "@/components/map/MapTile"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"

type TProps = {
  mapTiles: TMapTile[]
}

export default function MapBase({ mapTiles }: TProps) {
  return (
    <>
      {mapTiles.map((tile) => (
        <MapTile
          key={`${tile.mapTiles.x},${tile.mapTiles.y}`}
          mapTile={tile}
        />
      ))}
    </>
  )
}
