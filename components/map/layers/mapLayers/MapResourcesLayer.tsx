import ResourcesLayer from "@/components/map/layers/mapTileLayers/layers/ResourcesLayer"
import MapTile from "@/components/map/MapTile"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import { useResourcesLayer } from "@/methods/hooks/world/composite/useResourcesLayer"

type TProps = {
  mapTiles: TMapTile[]
}

export default function MapResourcesLayer({ mapTiles }: TProps) {
  const { combinedResourcesOnMap } = useResourcesLayer()

  return (
    <>
      {mapTiles.map((tile) => {
        const key = `${tile.mapTiles.x},${tile.mapTiles.y}`

        return (
          <MapTile
            key={key}
            mapTile={tile}
            layers={<ResourcesLayer knownMapTilesResourcesOnMap={combinedResourcesOnMap[key]} />}
          />
        )
      })}
    </>
  )
}
