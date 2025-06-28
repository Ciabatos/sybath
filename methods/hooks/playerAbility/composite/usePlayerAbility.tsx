"use client"

import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useFetchPlayerAbilities } from "@/methods/hooks/playerAbility/core/useFetchPlayerAbilities"
import { selectedAbilityIdAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"

export function usePlayerAbility() {
  const { playerAbilities } = useFetchPlayerAbilities()
  const selectedAbilityId = useAtomValue(selectedAbilityIdAtom)
  const setSelectedAbilityId = useSetAtom(selectedAbilityIdAtom)

  function selectAbility(abilityId: number) {
    setSelectedAbilityId(abilityId)
  }

  function doPlayerAbility(abilityId: number | undefined, clickedTile: TJoinedMapTile | undefined) {
    console.log("doPlayerAbility", abilityId, clickedTile)
  }

  return { playerAbilities, selectedAbilityId, selectAbility, doPlayerAbility }
}
