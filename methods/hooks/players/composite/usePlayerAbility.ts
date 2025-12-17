"use client"

import { useFetchPlayerAbilities } from "@/methods/hooks/attributes/core/useFetchPlayerAbilities"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function usePlayerAbility() {
  const { playerId } = usePlayerId()
  const { playerAbilities } = useFetchPlayerAbilities({ playerId })

  return { playerAbilities }
}
