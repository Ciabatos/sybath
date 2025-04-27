"use client"

import { mapTilesAbilityAction } from "@/methods/actions/mapTilesAbilityAction"
import { TTileCoordinates } from "@/methods/hooks/useMapTileClick"
import { mapTilesActionStatusAtom, selectedAbilityIdAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useSetAtom } from "jotai"

export function useActionPlayerAbility() {
  const setselectedAbilityIdAtom = useSetAtom(selectedAbilityIdAtom)
  const setOpenModalBottomCenterBar = useSetAtom(mapTilesActionStatusAtom)

  function handleClickOnPlayerAbility(abilityId: number) {
    setselectedAbilityIdAtom(abilityId)
    setOpenModalBottomCenterBar(EMapTilesActionStatus.UseAbilityAction)
  }

  function handleUsePlayerAbility(abilityId: number | undefined, clickedTile: TTileCoordinates) {
    if (abilityId === undefined) {
      return
    }
    mapTilesAbilityAction(abilityId, clickedTile)
  }
  return { handleClickOnPlayerAbility, handleUsePlayerAbility }
}
