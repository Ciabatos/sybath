"use client"

import { modalBottomCenterBarAtom } from "@/store/atoms"
import { EPanelsBottomCenterBar } from "@/types/enumeration/EPanelsBottomCenterBar"
import { componentMapBottomCenterBar } from "@/types/panels/componentMapBottomCenterBar"
import { useAtom } from "jotai"

export function useModalBottomCenterBar() {
  const [modalBottomCenterBar, setModalBottomCenterBar] = useAtom(modalBottomCenterBarAtom)
  const ModalBottomCenterBar = componentMapBottomCenterBar[modalBottomCenterBar]

  function resetModalBottomCenterBar() {
    setModalBottomCenterBar(EPanelsBottomCenterBar.Inactive)
  }

  return { ModalBottomCenterBar, setModalBottomCenterBar, resetModalBottomCenterBar }
}
