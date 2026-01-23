"use client"

import { useFetchAttributesAbilities } from "@/methods/hooks/attributes/core/useFetchAttributesAbilities"
import { useFetchPlayerAbilities } from "@/methods/hooks/attributes/core/useFetchPlayerAbilities"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { abilitiesAtom, playerAbilitiesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function usePlayerAbilities() {
  const { playerId } = usePlayerId()

  useFetchAttributesAbilities()
  const abilities = useAtomValue(abilitiesAtom)

  useFetchPlayerAbilities({ playerId })
  const playerAbilities = useAtomValue(playerAbilitiesAtom)

  const combinedPlayerAbilities = Object.entries(playerAbilities).map(([key, playerAbility]) => ({
    ...playerAbility,
    ...abilities[playerAbility.abilityId],
  }))

  return { abilities, playerAbilities, combinedPlayerAbilities }
}
