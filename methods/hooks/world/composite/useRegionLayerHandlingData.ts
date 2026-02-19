import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useFetchKnownMapRegion } from "@/methods/hooks/world/core/useFetchKnownMapRegion"
import { knownMapRegionAtom } from "@/store/atoms"

import { useAtomValue } from "jotai"

export function useRegionLayerHandlingData() {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()
  const regionType = 1

  useFetchKnownMapRegion({ mapId, playerId, regionType })
  const knownMapRegion = useAtomValue(knownMapRegionAtom)

  return {
    knownMapRegion,
  }
}
