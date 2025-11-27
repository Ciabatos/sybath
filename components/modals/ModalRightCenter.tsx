"use client"

import { PanelBuilding } from "@/components/panels/PanelBuilding"
import { PanelDistrict } from "@/components/panels/PanelDistrict"
import { PanelEmptyTilePanel } from "@/components/panels/PanelEmptyTilePanel"
import { useCityTilesActionStatus } from "@/methods/hooks/cities/composite/useCityTilesActionStatus"
import { useMapTilesActionStatus } from "@/methods/hooks/world/composite/useMapTilesActionStatus"

export function ModalRightCenter() {
  const { actualCityTileStatus } = useCityTilesActionStatus()
  const { actualMapTilesActionStatus } = useMapTilesActionStatus()

  return (
    <>
      {actualCityTileStatus.BuildingActionList && <PanelBuilding />}
      {actualMapTilesActionStatus.DistrictActionList && <PanelDistrict />}
      {actualMapTilesActionStatus.EmptyTileActionList && <PanelEmptyTilePanel />}
    </>
  )
}
