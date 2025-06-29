"use client"

import { ModalBuildingPanel } from "@/components/portals/modals/modalRightCenter/modalBuildingPanel/ModalBuildingPanel"
import { ModalDistrictPanel } from "@/components/portals/modals/modalRightCenter/modalDistrictPanel/ModalDistrictPanel"
import { ModalEmptyTilePanel } from "@/components/portals/modals/modalRightCenter/modalEmptyTilePanel/ModalEmptyTilePanel"
import { useCityTilesActionStatus } from "@/methods/hooks/cityTiles/core/useCityTilesActionStatus"
import { useMapTilesActionStatus } from "@/methods/hooks/mapTiles/core/useMapTilesActionStatus"

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
