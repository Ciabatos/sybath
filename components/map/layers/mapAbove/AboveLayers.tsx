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
 * Warstwy „nad" kafelkiem — liczniki i ikony.
 *
 * Składane przez `MapHandling` i przekazywane do `MapTile` jako `layers`.
 * Kolejność ma znaczenie: liczniki rysują się później, więc są na wierzchu.
 *
 * `detailLayer` dostajemy propem zamiast czytać atom tutaj, żeby każdy
 * z kilkuset kafelków nie subscribe'ował się do tego samego atomu.
 */
export default function AboveLayers({ tile, resources, detailLayer }: TProps) {
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