"use client"

import { modalTopCenterBarAtom } from "@/store/atoms"
import { EPanelsTopCenterBar } from "@/types/enumeration/EPanelsTopCenterBar"
import { panelTopCenterBar } from "@/types/panels/panelTopCenterBar"
import { useAtom } from "jotai"

export function useModalTopCenterBar() {
  const [modalTopCenterBar, setModalTopCenterBar] = useAtom(modalTopCenterBarAtom)
  const ModalTopCenterBar = panelTopCenterBar[modalTopCenterBar]

  function openModalTopCenterBar(panel: EPanelsTopCenterBar) {
    setModalTopCenterBar(panel)
  }

  function resetModalTopCenterBar() {
    setModalTopCenterBar(EPanelsTopCenterBar.Inactive)
  }

  return { ModalTopCenterBar, openModalTopCenterBar, resetModalTopCenterBar }
}
