"use client"

import { modalBottomCenterBarAtom } from "@/store/atoms"
import { EPanelsBottomCenter } from "@/types/enumeration/EPanelsBottomCenter"
import { panelBottomCenterBar } from "@/types/panels/panelBottomCenter"
import { useAtom } from "jotai"

export function useModalBottomCenterBar() {
  const [modalBottomCenterBar, setModalBottomCenterBar] = useAtom(modalBottomCenterBarAtom)
  const ModalBottomCenter = panelBottomCenterBar[modalBottomCenterBar]

  function openModalBottomCenterBar(panel: EPanelsBottomCenter) {
    setModalBottomCenterBar(panel)
  }

  function resetModalBottomCenterBar() {
    setModalBottomCenterBar(EPanelsBottomCenter.Inactive)
  }

  return { ModalBottomCenter, openModalBottomCenterBar, resetModalBottomCenterBar }
}
