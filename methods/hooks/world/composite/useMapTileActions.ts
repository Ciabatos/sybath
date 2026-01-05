"use client"

import { TJoinMap } from "@/methods/functions/deprecated/joinMap3"
import { useModalBottomCenterBar } from "@/methods/hooks/modals/useModalBottomCenterBar"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { useResetModals } from "@/methods/hooks/modals/useResetModals"
import { clickedTileAtom } from "@/store/atoms"
import { EPanels } from "@/types/enumeration/EPanels"
import { useAtom } from "jotai"

export function useMapTileActions() {
  const [clickedTile, setClickedTile] = useAtom(clickedTileAtom)
  const { setModalBottomCenterBarAtom } = useModalBottomCenterBar()
  const { setModalLeftTopBar } = useModalLeftTopBar()
  const { setModalRightCenter } = useModalRightCenter()
  const { setModalTopCenter } = useModalTopCenter()
  const { resetModals } = useResetModals()

  function handleClickOnMapTile(params: TJoinMap) {
    setClickedTile(params)
    if (params.cities?.name) {
      setModalRightCenter(EPanels.PanelCityActionBar)
    } else if (params.districts?.name) {
      setModalRightCenter(EPanels.PanelDistrict)
    } else {
      resetModals()
    }
  }

  return { clickedTile, handleClickOnMapTile }
}
