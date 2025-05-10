"use client"

import { mapTilesAbilityAction } from "@/methods/actions/mapTilesAbilityAction"
import { useFetchPlayerAbilities } from "@/methods/hooks/fetchers/useFetchPlayerAbilities"
import { TTileCoordinates } from "@/methods/hooks/useMapTileClick"
import { mapTilesActionStatusAtom, playerAbilitiesAtom, selectedAbilityIdAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue, useSetAtom } from "jotai"

export function usePlayerAbility() {
  useFetchPlayerAbilities()

  const playerAbilities = useAtomValue(playerAbilitiesAtom)
  const setSelectedAbilityIdAtom = useSetAtom(selectedAbilityIdAtom)
  const setOpenModalBottomCenterBar = useSetAtom(mapTilesActionStatusAtom)

  function handleClickOnPlayerAbility(abilityId: number) {
    setSelectedAbilityIdAtom(abilityId)
    setOpenModalBottomCenterBar(EMapTilesActionStatus.UseAbilityAction)
  }

  function handleUsePlayerAbility(abilityId: number | undefined, clickedTile: TTileCoordinates) {
    if (abilityId === undefined) {
      return
    }
    mapTilesAbilityAction(abilityId, clickedTile)
  }
  return { playerAbilities, handleClickOnPlayerAbility, handleUsePlayerAbility }
}
