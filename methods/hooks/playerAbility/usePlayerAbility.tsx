"use client"

import { mapTilesAbilityAction } from "@/methods/actions/mapTilesAbilityAction"
import { TTileCoordinates } from "@/methods/hooks/mapTiles/useMapTilesManipulation"
import { useFetchPlayerAbilities } from "@/methods/hooks/playerAbility/useFetchPlayerAbilities"
import { mapTilesActionStatusAtom, playerAbilitiesAtom, selectedAbilityIdAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtom, useAtomValue, useSetAtom } from "jotai"

export function usePlayerAbility() {
  useFetchPlayerAbilities()
  const playerAbilities = useAtomValue(playerAbilitiesAtom)

  const [selectedAbilityId, setSelectedAbilityId] = useAtom(selectedAbilityIdAtom)
  const setOpenModalBottomCenterBar = useSetAtom(mapTilesActionStatusAtom)

  function handleClickOnPlayerAbility(abilityId: number) {
    setSelectedAbilityId(abilityId)
    setOpenModalBottomCenterBar(EMapTilesActionStatus.UseAbilityAction)
  }

  function handleUsePlayerAbility(abilityId: number | undefined, clickedTile: TTileCoordinates) {
    if (abilityId === undefined) {
      setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
      return
    }
    mapTilesAbilityAction(abilityId, clickedTile)
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
  }

  function handleCancelPlayerAbility() {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
  }

  return { playerAbilities, selectedAbilityId, handleClickOnPlayerAbility, handleUsePlayerAbility, handleCancelPlayerAbility }
}
