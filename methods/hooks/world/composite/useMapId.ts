import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchPlayerMap, usePlayerMapState } from "@/methods/hooks/world/core/useFetchPlayerMap"

export function useMapId() {
  const { playerId } = usePlayerId()

  useFetchPlayerMap({ playerId })
  const playerMap = usePlayerMapState()

  const [playerMapData] = Object.values(playerMap)

  const mapId = playerMapData?.mapId

  return { mapId }
}
