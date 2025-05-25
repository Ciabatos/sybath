"use client"

import { ModalBuildingPanel } from "@/components/modals/modalRightCenter/ModalBuildingPanel"
import { ModalDistrictPanel } from "@/components/modals/modalRightCenter/ModalDistrictPanel"
import { ModalEmptyTilePanel } from "@/components/modals/modalRightCenter/ModalEmptyTilePanel"
import { cityTilesActionStatusAtom, mapTilesActionStatusAtom } from "@/store/atoms"
import { ECityTilesActionStatus } from "@/types/enumeration/CityTilesActionStatusEnum"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue } from "jotai"

export function ModalRightCenterHandling() {
  const cityTilesActionStatus = useAtomValue(cityTilesActionStatusAtom)
  const mapTilesActionStatus = useAtomValue(mapTilesActionStatusAtom)

  return (
    <>
      {cityTilesActionStatus === ECityTilesActionStatus.BuildingActionList && <ModalBuildingPanel />}
      {mapTilesActionStatus === EMapTilesActionStatus.DistrictActionList && <ModalDistrictPanel />}
      {mapTilesActionStatus === EMapTilesActionStatus.EmptyTileActionList && <ModalEmptyTilePanel />}
    </>
  )
}
