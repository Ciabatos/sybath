"use client"

import { modalRightCenterAtom } from "@/store/atoms"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { panelRightCenter } from "@/types/panels/panelRightCenter"
import { useAtom } from "jotai"

export function useModalRightCenter() {
  const [modalRightCenter, setModalRightCenter] = useAtom(modalRightCenterAtom)
  const ModalRightCenter = panelRightCenter[modalRightCenter]

  function openModalRightCenter(panel: EPanelsRightCenter) {
    setModalRightCenter(panel)
  }

  function resetModalRightCenter() {
    setModalRightCenter(EPanelsRightCenter.Inactive)
  }

  return { ModalRightCenter, openModalRightCenter, resetModalRightCenter }
}
