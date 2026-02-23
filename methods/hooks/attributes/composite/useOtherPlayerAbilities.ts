"use client"

import { useFetchAttributesAbilities } from "@/methods/hooks/attributes/core/useFetchAttributesAbilities"
import { useFetchOtherPlayerAbilities } from "@/methods/hooks/attributes/core/useFetchOtherPlayerAbilities"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { abilitiesAtom, otherPlayerAbilitiesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useOtherPlayerAbilities() {
  const { playerId } = usePlayerId()
  const otherPlayerMaskId = useOtherPlayerId()

  useFetchAttributesAbilities()
  const abilities = useAtomValue(abilitiesAtom)

  useFetchOtherPlayerAbilities({ playerId, otherPlayerMaskId })
  const otherPlayerAbilities = useAtomValue(otherPlayerAbilitiesAtom)

  const combinedOtherPlayerAbilities = Object.entries(otherPlayerAbilities).map(([key, playerAbility]) => ({
    ...playerAbility,
    ...abilities[playerAbility.abilityId],
  }))

  return { abilities, otherPlayerAbilities, combinedOtherPlayerAbilities }
}
