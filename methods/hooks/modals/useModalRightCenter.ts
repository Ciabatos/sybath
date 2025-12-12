// hooks/useModalRightCenter.ts
import { modalRightCenterAtom } from "@/store/atoms"
import { EPanels } from "@/types/enumeration/EPanels"
import { useAtom } from "jotai"
import { FC, useEffect, useState } from "react"
import { useLazyPanelLoader } from "./useLazyPanelLoader"

export function useModalRightCenter() {
  const [modalRightCenter, setModalRightCenter] = useAtom(modalRightCenterAtom)
  const { loadPanel } = useLazyPanelLoader()

  const [ModalRightCenter, setActivePanel] = useState<FC | null>(null)

  useEffect(() => {
    if (modalRightCenter === EPanels.Inactive) {
      setActivePanel(null)
      return
    }

    loadPanel(modalRightCenter).then((panel) => {
      setActivePanel(panel)
    })
  }, [modalRightCenter, loadPanel])

  return { ModalRightCenter, setModalRightCenter }
}
