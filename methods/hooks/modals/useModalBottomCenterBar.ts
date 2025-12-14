"use client"

import { modalBottomCenterBarAtom } from "@/store/atoms"
import { EPanels } from "@/types/enumeration/EPanels"
import { useAtom } from "jotai"
import { FC, useEffect, useState } from "react"
import { useLazyPanelLoader } from "./useLazyPanelLoader"

export function useModalBottomCenterBar() {
  const [modalBottomCenterBar, setModalBottomCenterBar] = useAtom(modalBottomCenterBarAtom)
  const { loadPanel } = useLazyPanelLoader()

  const [ModalBottomCenterBar, setActivePanel] = useState<FC<{ closePanel: () => void }> | null>(null)

  useEffect(() => {
    if (modalBottomCenterBar === EPanels.Inactive) {
      setActivePanel(null)
      return
    }

    loadPanel(modalBottomCenterBar).then((panel) => {
      setActivePanel(panel)
    })
  }, [modalBottomCenterBar, loadPanel])

  function resetModalBottomCenterBar() {
    setModalBottomCenterBar(EPanels.Inactive)
  }

  return { ModalBottomCenterBar, setModalBottomCenterBar, resetModalBottomCenterBar }
}
