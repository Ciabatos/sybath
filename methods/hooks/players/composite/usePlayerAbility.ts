"use client"

import { useFetchAttributesPlayerAbilitiesByKey } from "@/methods/hooks/attributes/core/useFetchAttributesPlayerAbilitiesByKey"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function usePlayerAbility() {
  const { playerId } = usePlayerId()
  const { playerAbilities } = useFetchAttributesPlayerAbilitiesByKey({ playerId })

  return { playerAbilities }
}
