"use client"

import { modalBottomCenterBarAtom } from "@/store/atoms"
import { EPanelsBottomCenterBar } from "@/types/enumeration/EPanelsBottomCenterBar"
import { panelBottomCenterBar } from "@/types/panels/panelBottomCenterBar"
import { useAtom } from "jotai"

export function useModalBottomCenterBar() {
  const [modalBottomCenterBar, setModalBottomCenterBar] = useAtom(modalBottomCenterBarAtom)
  const ModalBottomCenterBar = panelBottomCenterBar[modalBottomCenterBar]

  function openModalBottomCenterBar(panel: EPanelsBottomCenterBar) {
    setModalBottomCenterBar(panel)
  }

  function resetModalBottomCenterBar() {
    setModalBottomCenterBar(EPanelsBottomCenterBar.Inactive)
  }

  return { ModalBottomCenterBar, openModalBottomCenterBar, resetModalBottomCenterBar }
}
