"use client"

import { modalLeftTopBarAtom } from "@/store/atoms"
import { EPanels } from "@/types/enumeration/EPanels"
import { panelComponentMap } from "@/types/panels/leftTopBarComponents"
import { useAtom } from "jotai"

export function useModalLeftTopBar() {
  const [modalLeftTopBar, setModalLeftTopBar] = useAtom(modalLeftTopBarAtom)
  console.log("Current modalLeftTopBar value:", modalLeftTopBar)
  const ModalLeftTopBar = panelComponentMap[modalLeftTopBar]

  function resetModalLeftTopBar() {
    setModalLeftTopBar(EPanels.Inactive)
  }

  return { ModalLeftTopBar, setModalLeftTopBar, resetModalLeftTopBar }
}
