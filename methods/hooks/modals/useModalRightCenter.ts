"use client"

import { modalRightCenterAtom } from "@/store/atoms"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { panelComponentMap } from "@/types/panels/leftTopBarComponents"
import { useAtom } from "jotai"

export function useModalRightCenter() {
  const [modalRightCenter, setModalRightCenter] = useAtom(modalRightCenterAtom)
  const ModalRightCenter = panelComponentMap[modalRightCenter]

  function resetModalRightCenter() {
    setModalRightCenter(EPanelsRightCenter.Inactive)
  }

  return { ModalRightCenter, setModalRightCenter, resetModalRightCenter }
}
