"use client"

import {
  useAttributesAbilitiesState,
  useFetchAttributesAbilities,
} from "@/methods/hooks/attributes/core/useFetchAttributesAbilities"
import {
  useFetchPlayerAbilities,
  usePlayerAbilitiesState,
} from "@/methods/hooks/attributes/core/useFetchPlayerAbilities"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function usePlayerAbilities() {
  const { playerId } = usePlayerId()

  useFetchAttributesAbilities()
  const abilities = useAttributesAbilitiesState()

  useFetchPlayerAbilities({ playerId })
  const playerAbilities = usePlayerAbilitiesState()

  const combinedPlayerAbilities = Object.entries(playerAbilities).map(([key, playerAbility]) => ({
    ...playerAbility,
    ...abilities[playerAbility.abilityId],
  }))

  return { abilities, playerAbilities, combinedPlayerAbilities }
}
