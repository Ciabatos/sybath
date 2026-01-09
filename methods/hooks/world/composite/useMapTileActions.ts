"use client"

import { TMapTile } from "@/components/map/Map"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { useResetModals } from "@/methods/hooks/modals/useResetModals"
import { clickedTileAtom } from "@/store/atoms"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { useAtom } from "jotai"

export function useMapTileActions() {
  const [clickedTile, setClickedTile] = useAtom(clickedTileAtom)
  // const { setModalBottomCenterBarAtom } = useModalBottomCenterBar()
  const { setModalLeftTopBar } = useModalLeftTopBar()
  const { openModalRightCenter } = useModalRightCenter()
  const { setModalTopCenter } = useModalTopCenter()
  const { resetModals } = useResetModals()

  function handleClickOnMapTile(params: TMapTile) {
    setClickedTile(params)
    if (params.cities?.name) {
      openModalRightCenter(EPanelsRightCenter.PanelMapTileDetail)
    } else if (params.districts?.name) {
      openModalRightCenter(EPanelsRightCenter.PanelMapTileDetail)
    } else {
      openModalRightCenter(EPanelsRightCenter.PanelMapTileDetail)
      // resetModals()
    }
  }

  return { clickedTile, handleClickOnMapTile }
}
