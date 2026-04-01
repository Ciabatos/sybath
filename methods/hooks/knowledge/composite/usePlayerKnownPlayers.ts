import {
  useFetchPlayerKnownPlayers,
  usePlayerKnownPlayersState,
} from "@/methods/hooks/knowledge/core/useFetchPlayerKnownPlayers"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export default function usePlayerKnownPlayers() {
  const { playerId } = usePlayerId()

  useFetchPlayerKnownPlayers({ playerId })
  const playerKnownPlayers = usePlayerKnownPlayersState()

  return { playerKnownPlayers }
}
