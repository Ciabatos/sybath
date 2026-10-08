import MapTileLayers from "@/components/map/layers/mapTileLayers/layers/MapTileLayers"
import MapBase from "@/components/map/layers/mapLayers/MapBase"
import { useMapHandling } from "@/methods/hooks/world/composite/useMapHandling"
import { useResourcesLayer } from "@/methods/hooks/world/composite/useResourcesLayer"
import { activeLayerAtom } from "@/store/atoms"
import { useAtom } from "jotai"

/**
 * Baza (terrain, miasta, gracz, liczniki) jest zawsze.
 * Warstwa szczegółów jest jedna i wyłączna — patrz `activeLayerAtom`.
 */
export default function MapHandling() {
  const [activeLayer] = useAtom(activeLayerAtom)
  const { combinedMap } = useMapHandling()
  const { combinedResourcesOnMap } = useResourcesLayer()

  return (
    <MapBase
      mapTiles={combinedMap}
      renderLayers={(tile) => (
        <MapTileLayers
          tile={tile}
          resources={combinedResourcesOnMap[`${tile.mapTiles.x},${tile.mapTiles.y}`]}
          detailLayer={activeLayer.layer}
        />
      )}
    />
  )
}