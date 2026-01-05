import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchPlayerMap } from "@/methods/hooks/world/core/useFetchPlayerMap"

export function useMapId() {
  const { playerId } = usePlayerId()
  const { playerMap } = useFetchPlayerMap({ playerId })

  const mapId = Object.values(playerMap)[0].mapId

  return { mapId }
}
