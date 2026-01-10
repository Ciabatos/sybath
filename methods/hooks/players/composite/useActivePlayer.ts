"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchActivePlayer } from "@/methods/hooks/players/core/useFetchActivePlayer"

export function useActivePlayer() {
  const { playerId } = usePlayerId()
  const { activePlayer } = useFetchActivePlayer({ playerId })
  console.log("Active Player:", activePlayer)
  const playerValue = Object.values(activePlayer)[0]

  return { activePlayer: playerValue }
}
