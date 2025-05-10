"use client"

import { mapTilesAbilityAction } from "@/methods/actions/mapTilesAbilityAction"
import { useFetchAbilityRequirements } from "@/methods/hooks/fetchers/useFetchAbilityRequirements"
import { useFetchPlayerAbilities } from "@/methods/hooks/fetchers/useFetchPlayerAbilities"
import { TTileCoordinates } from "@/methods/hooks/mapTiles/useMapTilesManipulation"
import { abilityRequirementsAtom, mapTilesActionStatusAtom, playerAbilitiesAtom, selectedAbilityIdAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtom, useAtomValue, useSetAtom } from "jotai"

export function usePlayerAbility() {
  useFetchPlayerAbilities()

  const playerAbilities = useAtomValue(playerAbilitiesAtom)
  const [selectedAbilityId, setSelectedAbilityId] = useAtom(selectedAbilityIdAtom)
  const setOpenModalBottomCenterBar = useSetAtom(mapTilesActionStatusAtom)

  useFetchAbilityRequirements(selectedAbilityId)
  const abilityRequirements = useAtomValue(abilityRequirementsAtom)

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

  return { playerAbilities, selectedAbilityId, abilityRequirements, handleClickOnPlayerAbility, handleUsePlayerAbility, handleCancelPlayerAbility }
}
