"use client"
import { useActivePlayerState, useFetchActivePlayer } from "@/methods/hooks/players/core/useFetchActivePlayer"

export function usePlayerId() {
  useFetchActivePlayer()
  const activePlayerData = useActivePlayerState()

  const [activePlayer] = Object.values(activePlayerData)

  const playerId = activePlayer?.id

  return { playerId }
}
