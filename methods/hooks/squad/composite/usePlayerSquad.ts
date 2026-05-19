"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchSquad, useSquadState } from "@/methods/hooks/squad/core/useFetchSquad"

export function usePlayerSquad() {
  const { playerId } = usePlayerId()
  useFetchSquad({ playerId })
  const activePlayerSquadData = useSquadState()

  const [activePlayerSquad] = Object.values(activePlayerSquadData)

  return { activePlayerSquad }
}
