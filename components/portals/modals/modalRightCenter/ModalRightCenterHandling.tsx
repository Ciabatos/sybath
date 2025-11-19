"use client"

import { ModalBuildingPanel } from "@/components/portals/modals/modalRightCenter/modalBuildingPanel/ModalBuildingPanel"
import { ModalDistrictPanel } from "@/components/portals/modals/modalRightCenter/modalDistrictPanel/ModalDistrictPanel"
import { ModalEmptyTilePanel } from "@/components/portals/modals/modalRightCenter/modalEmptyTilePanel/ModalEmptyTilePanel"
import { useCityTilesActionStatus } from "@/methods/hooks/map/composite/useCityTilesActionStatus"
import { useMapTilesActionStatus } from "@/methods/hooks/map/composite/useMapTilesActionStatus"

export function ModalRightCenterHandling() {
  const { actualCityTileStatus } = useCityTilesActionStatus()
  const { actualMapTilesActionStatus } = useMapTilesActionStatus()

  return (
    <>
      {actualCityTileStatus.BuildingActionList && <ModalBuildingPanel />}
      {actualMapTilesActionStatus.DistrictActionList && <ModalDistrictPanel />}
      {actualMapTilesActionStatus.EmptyTileActionList && <ModalEmptyTilePanel />}
    </>
  )
}
