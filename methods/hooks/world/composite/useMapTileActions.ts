"use client"

import { TMapTile } from "@/components/map/Map"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { clickedTileAtom } from "@/store/atoms"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { useAtom } from "jotai"

export function useMapTileActions() {
  const [clickedTile, setClickedTile] = useAtom(clickedTileAtom)
  const { openModalRightCenter } = useModalRightCenter()

  function handleClickOnMapTile(params: TMapTile) {
    setClickedTile(params)
    if (params.cities?.name) {
      openModalRightCenter(EPanelsRightCenter.PanelMapTileDetail)
    } else if (params.districts?.name) {
      openModalRightCenter(EPanelsRightCenter.PanelMapTileDetail)
    } else {
      openModalRightCenter(EPanelsRightCenter.PanelMapTileDetail)
    }
  }

  return { clickedTile, handleClickOnMapTile }
}
