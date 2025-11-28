"use client"

import { cityTilesActionStatusAtom } from "@/store/atoms"
import { ECityTilesActionStatus } from "@/types/enumeration/CityTilesActionStatusEnum"
import { useAtomValue, useSetAtom } from "jotai"

export function useCityTilesActionStatus() {
  const cityTilesActionStatus = useAtomValue(cityTilesActionStatusAtom)
  const setCityTilesActionStatus = useSetAtom(cityTilesActionStatusAtom)

  // const actualCityTileStatus = {
  //   Inactive: cityTilesActionStatus === ECityTilesActionStatus.Inactive,
  //   BuildingActionList: cityTilesActionStatus === ECityTilesActionStatus.BuildingActionList,
  // }

  // const newCityTilesActionStatus = {
  //   Inactive: () => setCityTilesActionStatus(ECityTilesActionStatus.Inactive),
  //   BuildingActionList: () => setCityTilesActionStatus(ECityTilesActionStatus.BuildingActionList),
  // }

  // function resetNewCityTilesActionStatus() {
  //   setCityTilesActionStatus(ECityTilesActionStatus.Inactive)
  // }
  // return { actualCityTileStatus, newCityTilesActionStatus, resetNewCityTilesActionStatus }
}
