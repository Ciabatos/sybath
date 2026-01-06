"use client"

import { modalLeftTopBarAtom } from "@/store/atoms"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import { panelComponentMap } from "@/types/panels/leftTopBarComponents"
import { useAtom } from "jotai"

export function useModalLeftTopBar() {
  const [modalLeftTopBar, setModalLeftTopBar] = useAtom(modalLeftTopBarAtom)
  const ModalLeftTopBar = panelComponentMap[modalLeftTopBar]

  function resetModalLeftTopBar() {
    setModalLeftTopBar(EPanelsLeftTopBar.Inactive)
  }

  return { ModalLeftTopBar, setModalLeftTopBar, resetModalLeftTopBar }
}
