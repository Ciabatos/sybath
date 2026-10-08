import MapBase from "@/components/map/MapBase"
import HeroesLayer from "@/components/map/layers/heroes/HeroesLayer"
import ResourcesLayer from "@/components/map/layers/resources/ResourcesLayer"
import { useMapHandling } from "@/methods/hooks/world/composite/useMapHandling"
import { useResourcesLayer } from "@/methods/hooks/world/composite/useResourcesLayer"
import { activeLayerAtom, MAP_LAYERS } from "@/store/atoms/client/activeLayerAtom"
import { useAtom } from "jotai"

/**
 * Wybiera warstwy dla każdego kafelka i przekazuje je do `MapBase`.
 *
 * Warstwy są przełączane WYŁĄCZNIE — jedna naraz, patrz `activeLayerAtom`.
 * Obie i tak rysują zlicznik; przełącznik decyduje tylko o tym, czy zamiast
 * niego rozwiniemy ikony. Dzięki temu mapa wygląda tak samo przed włączeniem
 * czegokolwiek.
 *
 * Ten plik jest jedynym miejscem, w którym warstwy trafiają na kafelek — przy
 * dodawaniu nowej warstwy nie trzeba dotykać `MapTile`.
 */
export default function MapHandling() {
  const [activeLayer] = useAtom(activeLayerAtom)
  const { combinedMap } = useMapHandling()
  const { combinedResourcesOnMap } = useResourcesLayer()

  return (
    <MapBase
      mapTiles={combinedMap}
      renderLayers={(tile) => (
        <>
          <ResourcesLayer
            resources={combinedResourcesOnMap[`${tile.mapTiles.x},${tile.mapTiles.y}`]}
            showDetail={activeLayer.layer === MAP_LAYERS.resources}
          />
          <HeroesLayer
            tile={tile}
            showDetail={activeLayer.layer === MAP_LAYERS.heroes}
          />
        </>
      )}
    />
  )
}