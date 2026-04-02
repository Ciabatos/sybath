"use client"

import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import { clickedMapTileAtom } from "@/store/atoms"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { useAtom } from "jotai"

export function useMapTileActions() {
  const [clickedMapTile, setClickedMapTile] = useAtom(clickedMapTileAtom)
  const { ModalRightCenter, openModalRightCenter } = useModalRightCenter()

  function handleClickOnMapTile(params: TMapTile) {
    setClickedMapTile(params)
    if (!ModalRightCenter) {
      openModalRightCenter(EPanelsRightCenter.MapTileDetail)
    }
  }

  return { clickedMapTile, handleClickOnMapTile }
}
