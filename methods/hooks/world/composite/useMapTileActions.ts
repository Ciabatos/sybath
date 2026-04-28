"use client"

import { useModalBottomLeft } from "@/methods/hooks/modals/useModalBottomLeft"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import { clickedMapTileAtom } from "@/store/atoms"
import { EPanelsBottomLeft } from "@/types/enumeration/EPanelsBottomLeft"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { useAtom } from "jotai"

export function useMapTileActions() {
  const [clickedMapTile, setClickedMapTile] = useAtom(clickedMapTileAtom)
  const { ModalRightCenter, openModalRightCenter } = useModalRightCenter()
  const { ModalBottomLeft, openModalBottomLeft } = useModalBottomLeft()

  function handleClickOnMapTile(params: TMapTile) {
    setClickedMapTile(params)
    if (!ModalRightCenter) {
      openModalRightCenter(EPanelsRightCenter.MapTileDetail)
    }
    if (!ModalBottomLeft) {
      openModalBottomLeft(EPanelsBottomLeft.PlayersOnTile)
    }
  }

  return { clickedMapTile, handleClickOnMapTile }
}
