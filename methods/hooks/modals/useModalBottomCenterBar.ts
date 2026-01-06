"use client"

import { modalBottomCenterBarAtom } from "@/store/atoms"
import { EPanels } from "@/types/enumeration/EPanels"
import { panelComponentMap } from "@/types/panels/leftTopBarComponents"
import { useAtom } from "jotai"

export function useModalBottomCenterBar() {
  const [modalBottomCenterBar, setModalBottomCenterBar] = useAtom(modalBottomCenterBarAtom)
  const ModalBottomCenterBar = panelComponentMap[modalBottomCenterBar]

  function resetModalBottomCenterBar() {
    setModalBottomCenterBar(EPanels.Inactive)
  }

  return { ModalBottomCenterBar, setModalBottomCenterBar, resetModalBottomCenterBar }
}
