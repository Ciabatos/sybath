import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import {
  useFetchKnownMapTilesResourcesOnMap,
  useKnownMapTilesResourcesOnMapState,
} from "@/methods/hooks/world/core/useFetchKnownMapTilesResourcesOnMap"

export function useResourcesLayer() {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()

  useFetchKnownMapTilesResourcesOnMap({ mapId, playerId })
  const knownMapTilesResourcesOnMap = useKnownMapTilesResourcesOnMapState()

  return { knownMapTilesResourcesOnMap }
}
