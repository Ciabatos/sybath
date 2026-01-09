"use client"

import { modalBottomCenterBarAtom } from "@/store/atoms"
import { EPanelsBottomCenterBar } from "@/types/enumeration/EPanelsBottomCenterBar"
import { componentMapBottomCenterBar } from "@/types/panels/componentMapBottomCenterBar"
import { useAtom } from "jotai"

export function useModalBottomCenterBar() {
  const [modalBottomCenterBar, setModalBottomCenterBar] = useAtom(modalBottomCenterBarAtom)
  const ModalBottomCenterBar = componentMapBottomCenterBar[modalBottomCenterBar]

  function openModalBottomCenterBar(panel: EPanelsBottomCenterBar) {
    // setModalTopCenter(EPanelsTopCenter.Inactive) // reset TopCenter
    setModalBottomCenterBar(panel)
  }

  function resetModalBottomCenterBar() {
    setModalBottomCenterBar(EPanelsBottomCenterBar.Inactive)
  }

  return { ModalBottomCenterBar, openModalBottomCenterBar, resetModalBottomCenterBar }
}
