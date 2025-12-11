"use client"

import { useFetchAttributesPlayerAbilitiesByKey } from "@/methods/hooks/attributes/core/useFetchAttributesPlayerAbilitiesByKey"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { selectedAbilityIdAtom } from "@/store/atoms"
import { useAtom } from "jotai"

export function usePlayerAbility() {
  const { playerId } = usePlayerId()
  const { playerAbilities } = useFetchAttributesPlayerAbilitiesByKey({ playerId })
  const [selectedAbilityId, setSelectedAbilityId] = useAtom(selectedAbilityIdAtom)

  function selectAbility(abilityId: number) {
    setSelectedAbilityId(abilityId)
  }

  return { playerAbilities, selectedAbilityId, selectAbility }
}
