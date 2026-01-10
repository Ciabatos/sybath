"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchActivePlayer } from "@/methods/hooks/players/core/useFetchActivePlayer"

export function useActivePlayer() {
  const { playerId } = usePlayerId()
  const { activePlayer } = useFetchActivePlayer({ playerId })

  return { activePlayer }
}
