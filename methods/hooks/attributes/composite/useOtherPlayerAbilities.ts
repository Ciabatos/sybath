"use client"

import {
  useAttributesAbilitiesState,
  useFetchAttributesAbilities,
} from "@/methods/hooks/attributes/core/useFetchAttributesAbilities"
import {
  useFetchOtherPlayerAbilities,
  useOtherPlayerAbilitiesState,
} from "@/methods/hooks/attributes/core/useFetchOtherPlayerAbilities"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function useOtherPlayerAbilities() {
  const { playerId } = usePlayerId()
  const otherPlayerId = useOtherPlayerId()

  useFetchAttributesAbilities()
  const abilities = useAttributesAbilitiesState()

  useFetchOtherPlayerAbilities({ playerId, otherPlayerId })
  const otherPlayerAbilities = useOtherPlayerAbilitiesState()

  const combinedOtherPlayerAbilities = Object.entries(otherPlayerAbilities).map(([key, playerAbility]) => ({
    ...playerAbility,
    ...abilities[playerAbility.abilityId],
  }))

  return { abilities, otherPlayerAbilities, combinedOtherPlayerAbilities }
}
