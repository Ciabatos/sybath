"use client"

import { modalBottomCenterBarAtom } from "@/store/atoms"
import { EPanelsBottomCenterBar } from "@/types/enumeration/EPanelsBottomCenterBar"
import { panelComponentMap } from "@/types/panels/leftTopBarComponents"
import { useAtom } from "jotai"

export function useModalBottomCenterBar() {
  const [modalBottomCenterBar, setModalBottomCenterBar] = useAtom(modalBottomCenterBarAtom)
  const ModalBottomCenterBar = panelComponentMap[modalBottomCenterBar]

  function resetModalBottomCenterBar() {
    setModalBottomCenterBar(EPanelsBottomCenterBar.Inactive)
  }

  return { ModalBottomCenterBar, setModalBottomCenterBar, resetModalBottomCenterBar }
}
