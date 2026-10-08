import MapBase from "@/components/map/layers/mapLayers/MapBase"
import ResourcesLayer from "@/components/map/layers/mapTileLayers/layers/ResourcesLayer"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import { useResourcesLayer } from "@/methods/hooks/world/composite/useResourcesLayer"

type TProps = {
  mapTiles: TMapTile[]
}

/**
 * Pętla po kafelkach żyje w MapBase — tu tylko dostarczamy warstwę zasobów,
 * żeby oba warianty nie duplikowały mapowania i budowania klucza.
 */
export default function MapResourcesLayer({ mapTiles }: TProps) {
  const { combinedResourcesOnMap } = useResourcesLayer()

  return (
    <MapBase
      mapTiles={mapTiles}
      renderLayers={(tile) => (
        <ResourcesLayer
          knownMapTilesResourcesOnMap={combinedResourcesOnMap[`${tile.mapTiles.x},${tile.mapTiles.y}`]}
        />
      )}
    />
  )
}