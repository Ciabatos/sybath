import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useFetchKnownMapRegion, useKnownMapRegionState } from "@/methods/hooks/world/core/useFetchKnownMapRegion"

export function useRegionLayerProvince() {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()
  const regionType = 1

  useFetchKnownMapRegion({ mapId, playerId, regionType })
  const knownMapRegion = useKnownMapRegionState()

  return {
    knownMapRegion,
  }
}
