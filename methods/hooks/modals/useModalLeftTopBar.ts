"use client"

import { modalLeftTopBarAtom } from "@/store/atoms"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import { panelLeftTopBar } from "@/types/panels/panelLeftTopBar"
import { useAtom } from "jotai"

export function useModalLeftTopBar() {
  const [modalLeftTopBar, setModalLeftTopBar] = useAtom(modalLeftTopBarAtom)
  const ModalLeftTopBar = panelLeftTopBar[modalLeftTopBar]

  function openModalLeftTopBar(panel: EPanelsLeftTopBar) {
    setModalLeftTopBar(panel)
  }

  function resetModalLeftTopBar() {
    setModalLeftTopBar(EPanelsLeftTopBar.Inactive)
  }

  return { ModalLeftTopBar, openModalLeftTopBar, resetModalLeftTopBar }
}
