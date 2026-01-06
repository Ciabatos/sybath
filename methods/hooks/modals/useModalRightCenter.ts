"use client"

import { modalRightCenterAtom } from "@/store/atoms"
import { EPanels } from "@/types/enumeration/EPanels"
import { panelComponentMap } from "@/types/panels/leftTopBarComponents"
import { useAtom } from "jotai"

export function useModalRightCenter() {
  const [modalRightCenter, setModalRightCenter] = useAtom(modalRightCenterAtom)
  const ModalRightCenter = panelComponentMap[modalRightCenter]

  function resetModalRightCenter() {
    setModalRightCenter(EPanels.Inactive)
  }

  return { ModalRightCenter, setModalRightCenter, resetModalRightCenter }
}
