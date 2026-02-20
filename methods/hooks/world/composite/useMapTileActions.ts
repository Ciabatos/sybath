"use client"

import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import { clickedTileAtom } from "@/store/atoms"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { useAtom } from "jotai"

export function useMapTileActions() {
  const [clickedTile, setClickedTile] = useAtom(clickedTileAtom)
  const { ModalRightCenter, openModalRightCenter } = useModalRightCenter()

  function handleClickOnMapTile(params: TMapTile) {
    setClickedTile(params)
    if (!ModalRightCenter) {
      openModalRightCenter(EPanelsRightCenter.PanelMapTileDetail)
    }
  }

  return { clickedTile, handleClickOnMapTile }
}
