"use client"

import { useFetchActivePlayer } from "@/methods/hooks/players/core/useFetchActivePlayer"

export function useActivePlayer() {
  const { activePlayer } = useFetchActivePlayer()
  const playerValue = Object.values(activePlayer)[0]

  return { activePlayer: playerValue }
}
