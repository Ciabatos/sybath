"use client"

import { mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue, useSetAtom } from "jotai"

export function useMapTilesActionStatus() {
  const mapTilesActionStatus = useAtomValue(mapTilesActionStatusAtom)
  const setMapTilesActionStatus = useSetAtom(mapTilesActionStatusAtom)

  const actualMapTilesActionStatus = {
    Inactive: mapTilesActionStatus === EMapTilesActionStatus.Inactive,
    CityActionList: mapTilesActionStatus === EMapTilesActionStatus.CityActionList,
    DistrictActionList: mapTilesActionStatus === EMapTilesActionStatus.DistrictActionList,
    EmptyTileActionList: mapTilesActionStatus === EMapTilesActionStatus.EmptyTileActionList,
    GuardAreaAction: mapTilesActionStatus === EMapTilesActionStatus.GuardAreaAction,
    MovementAction: mapTilesActionStatus === EMapTilesActionStatus.MovementAction,
    PlayerActionList: mapTilesActionStatus === EMapTilesActionStatus.PlayerActionList,
    UseAbilityAction: mapTilesActionStatus === EMapTilesActionStatus.UseAbilityAction,
  }

  const newMapTilesActionStatus = {
    Inactive: () => setMapTilesActionStatus(EMapTilesActionStatus.Inactive),
    CityActionList: () => setMapTilesActionStatus(EMapTilesActionStatus.CityActionList),
    DistrictActionList: () => setMapTilesActionStatus(EMapTilesActionStatus.DistrictActionList),
    EmptyTileActionList: () => setMapTilesActionStatus(EMapTilesActionStatus.EmptyTileActionList),
    GuardAreaAction: () => setMapTilesActionStatus(EMapTilesActionStatus.GuardAreaAction),
    MovementAction: () => setMapTilesActionStatus(EMapTilesActionStatus.MovementAction),
    PlayerActionList: () => setMapTilesActionStatus(EMapTilesActionStatus.PlayerActionList),
    UseAbilityAction: () => setMapTilesActionStatus(EMapTilesActionStatus.UseAbilityAction),
  }

  function resetMapTilesActionStatus() {
    setMapTilesActionStatus(EMapTilesActionStatus.Inactive)
  }

  return { actualMapTilesActionStatus, newMapTilesActionStatus, resetMapTilesActionStatus }
}
