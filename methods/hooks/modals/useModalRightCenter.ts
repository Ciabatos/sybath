"use client"

import { modalRightCenterAtom } from "@/store/atoms"
import { EPanels } from "@/types/enumeration/EPanels"
import { useAtom } from "jotai"
import { FC, useEffect, useState } from "react"
import { useLazyPanelLoader } from "./useLazyPanelLoader"

export function useModalRightCenter() {
  const [modalRightCenter, setModalRightCenter] = useAtom(modalRightCenterAtom)
  const { loadPanel } = useLazyPanelLoader()

  const [ModalRightCenter, setActivePanel] = useState<FC<{ closePanel: () => void }> | null>(null)

  useEffect(() => {
    if (modalRightCenter === EPanels.Inactive) {
      setActivePanel(null)
      return
    }

    loadPanel(modalRightCenter).then((panel) => {
      setActivePanel(panel)
    })
  }, [modalRightCenter, loadPanel])

  function resetModalRightCenter() {
    setModalRightCenter(EPanels.Inactive)
  }

  return { ModalRightCenter, setModalRightCenter, resetModalRightCenter }
}
