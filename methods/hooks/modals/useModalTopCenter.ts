import { modalTopCenterAtom } from "@/store/atoms"
import { EPanels } from "@/types/enumeration/EPanels"
import { useAtom } from "jotai"
import { FC, useEffect, useState } from "react"
import { useLazyPanelLoader } from "./useLazyPanelLoader"

export function useModalTopCenter() {
  const [modalTopCenter, setModalTopCenter] = useAtom(modalTopCenterAtom)
  const { loadPanel } = useLazyPanelLoader()

  const [ModalTopCenterPanel, setActivePanel] = useState<FC | null>(null)

  useEffect(() => {
    if (modalTopCenter === EPanels.Inactive) {
      setActivePanel(null)
      return
    }

    loadPanel(modalTopCenter).then((panel) => {
      setActivePanel(panel)
    })
  }, [modalTopCenter, loadPanel])

  return { ModalTopCenterPanel, setModalTopCenter }
}
