"use client"

import { TJoinCity } from "@/methods/functions/city/joinCity"
import { useModalBottomCenterBar } from "@/methods/hooks/modals/useModalBottomCenterBar"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { useResetModals } from "@/methods/hooks/modals/useResetModals"
import { clickedCityTileAtom } from "@/store/atoms"
import { EPanels } from "@/types/enumeration/EPanels"
import { useAtom } from "jotai"

export function useCityTilesActions() {
  const [clickedCityTile, setClickedCityTile] = useAtom(clickedCityTileAtom)
  const { setModalBottomCenterBarAtom } = useModalBottomCenterBar()
  const { setModalLeftTopBar } = useModalLeftTopBar()
  const { setModalRightCenter } = useModalRightCenter()
  const { setModalTopCenter } = useModalTopCenter()
  const { resetModals } = useResetModals()

  function handleClickOnCityTile(params: TJoinCity) {
    setClickedCityTile(params)
    if (params.buildings?.id) {
      setModalRightCenter(EPanels.PanelBuilding)
    } else {
      resetModals()
    }
  }

  return { clickedCityTile, handleClickOnCityTile }
}
