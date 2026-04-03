"use client"

import { useAllAbilitiesState, useFetchAllAbilities } from "@/methods/hooks/attributes/core/useFetchAllAbilities"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function useAllAbilities() {
  const { playerId } = usePlayerId()
  useFetchAllAbilities({ playerId })
  const allAbilities = useAllAbilitiesState()

  return { allAbilities }
}
