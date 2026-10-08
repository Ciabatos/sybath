import MapBase from "@/components/map/layers/mapLayers/MapBase"
import MapResourcesLayer from "@/components/map/layers/mapLayers/MapResourcesLayer"
import { useMapHandling } from "@/methods/hooks/world/composite/useMapHandling"
import { activeLayerAtom } from "@/store/atoms"
import { useAtom } from "jotai"

export default function MapHandling() {
  const [activeLayer] = useAtom(activeLayerAtom)
  const { combinedMap } = useMapHandling()

  if (activeLayer.resources) {
    return <MapResourcesLayer mapTiles={combinedMap} />
  }

  return <MapBase mapTiles={combinedMap} />
}