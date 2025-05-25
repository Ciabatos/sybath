"use client"

import { ModalBuildingPanel } from "@/components/modals/modalRightCenter/ModalBuildingPanel"
import { cityTilesActionStatusAtom } from "@/store/atoms"
import { ECityTilesActionStatus } from "@/types/enumeration/CityTilesActionStatusEnum"
import { useAtomValue } from "jotai"

export function ModalRightCenterHandling() {
  const cityTilesActionStatus = useAtomValue(cityTilesActionStatusAtom)

  return cityTilesActionStatus === ECityTilesActionStatus.BuildingActionList && <ModalBuildingPanel />
}
