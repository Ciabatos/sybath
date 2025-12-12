import { modalLeftTopBarAtom } from "@/store/atoms"
import { EPanels } from "@/types/enumeration/EPanels"
import { useAtom } from "jotai"
import { FC, useEffect, useState } from "react"
import { useLazyPanelLoader } from "./useLazyPanelLoader"

export function useModalLeftTopBar() {
  const [modalLeftTopBar, setModalLeftTopBar] = useAtom(modalLeftTopBarAtom)
  const { loadPanel } = useLazyPanelLoader()

  const [ModalLeftTopBar, setActivePanel] = useState<FC | null>(null)

  useEffect(() => {
    if (modalLeftTopBar === EPanels.Inactive) {
      setActivePanel(null)
      return
    }

    loadPanel(modalLeftTopBar).then((panel) => {
      setActivePanel(panel)
    })
  }, [modalLeftTopBar, loadPanel])

  return { ModalLeftTopBar, setModalLeftTopBar }
}
