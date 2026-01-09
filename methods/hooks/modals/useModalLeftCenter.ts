"use client"

import { modalLeftCenterAtom } from "@/store/atoms"
import { EPanelsLeftCenter } from "@/types/enumeration/EPanelsLeftCenter"
import { panelLeftCenter } from "@/types/panels/panelLeftCenter"
import { useAtom } from "jotai"

export function useModalLeftCenter() {
  const [modalLeftCenter, setModalLeftCenter] = useAtom(modalLeftCenterAtom)
  const ModalLeftCenter = panelLeftCenter[modalLeftCenter]

  function openModalLeftCenter(panel: EPanelsLeftCenter) {
    setModalLeftCenter(panel)
  }

  function resetModalLeftCenter() {
    setModalLeftCenter(EPanelsLeftCenter.Inactive)
  }

  return { ModalLeftCenter, openModalLeftCenter, resetModalLeftCenter }
}
