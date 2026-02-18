import { useFetchWorldMapTilesMapRegions } from "@/methods/hooks/world/core/useFetchWorldMapTilesMapRegions"
import { mapTilesMapRegionsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useRegionLayerHandlingData() {
  useFetchWorldMapTilesMapRegions()
  const mapTilesMapRegions = useAtomValue(mapTilesMapRegionsAtom)

  return {
    mapTilesMapRegions,
  }
}
