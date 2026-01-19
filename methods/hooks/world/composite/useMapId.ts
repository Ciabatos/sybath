import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchPlayerMap } from "@/methods/hooks/world/core/useFetchPlayerMap"
import { playerMapAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useMapId() {
  const { playerId } = usePlayerId()

  useFetchPlayerMap({ playerId })
  const playerMap = useAtomValue(playerMapAtom)

  const playerMapData = Object.values(playerMap)[0] ?? null
  const mapId = playerMapData?.mapId

  return { mapId }
}
