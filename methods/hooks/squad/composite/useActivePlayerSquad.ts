"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import {
  useActivePlayerSquadState,
  useFetchActivePlayerSquad,
} from "@/methods/hooks/squad/core/useFetchActivePlayerSquad"

export function useActivePlayerSquad() {
  const { playerId } = usePlayerId()

  useFetchActivePlayerSquad({ playerId })
  const activePlayerSquadData = useActivePlayerSquadState()

  const [activePlayerSquad] = Object.values(activePlayerSquadData)

  return { activePlayerSquad }
}
