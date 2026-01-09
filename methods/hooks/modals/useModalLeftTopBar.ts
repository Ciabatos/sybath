"use client"

import { modalLeftTopBarAtom } from "@/store/atoms"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import { componentMapLeftTopBar } from "@/types/panels/componentMapLeftTopBar"
import { useAtom } from "jotai"

export function useModalLeftTopBar() {
  const [modalLeftTopBar, setModalLeftTopBar] = useAtom(modalLeftTopBarAtom)
  const ModalLeftTopBar = componentMapLeftTopBar[modalLeftTopBar]

  function openModalLeftTopBar(panel: EPanelsLeftTopBar) {
    // setModalTopCenter(EPanelsTopCenter.Inactive) // reset TopCenter
    setModalLeftTopBar(panel)
  }
  
  function resetModalLeftTopBar() {
    setModalLeftTopBar(EPanelsLeftTopBar.Inactive)
  }

  return { ModalLeftTopBar, openModalLeftTopBar, resetModalLeftTopBar }
}
