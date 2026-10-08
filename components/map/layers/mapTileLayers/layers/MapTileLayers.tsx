import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import { TCombinedResourcesOnMap } from "@/methods/hooks/world/composite/useResourcesLayer"
import { MAP_LAYERS, TMapLayer } from "@/store/atoms/client/activeLayerAtom"
import TileLayerHeroes from "./TileLayerHeroes"
import TileLayerResources from "./TileLayerResources"

type TProps = {
  tile: TMapTile
  resources?: TCombinedResourcesOnMap[string]
  detailLayer: TMapLayer
}

/**
 * Warstwy szczegółowe kafelka.
 *
 * Baza (terrain, miasta, marker gracza, plan ruchu) renderuje się zawsze w
 * `MapTile` / `MapTileLayerUnderneathHandling` — tu decydujemy wyłącznie o tym, czy
 * dany kafelek pokazuje zlicznik, czy rozwinięte ikony.
 *
 * `detailLayer` przekazujemy z `MapHandling` zamiast czytać atom tutaj, żeby
 * każdy z kilkuset kafelków nie subscribe'ował się do tego samego atomu.
 */
export default function MapTileLayers({ tile, resources, detailLayer }: TProps) {
  return (
    <>
      <TileLayerResources
        resources={resources}
        showDetail={detailLayer === MAP_LAYERS.resources}
      />
      <TileLayerHeroes
        tile={tile}
        showDetail={detailLayer === MAP_LAYERS.heroes}
      />
    </>
  )
}