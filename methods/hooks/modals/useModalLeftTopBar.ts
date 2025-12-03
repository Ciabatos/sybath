import { modalLeftTopBarAtom } from "@/store/atoms"
import { EPanels } from "@/types/enumeration/EPanels"
import { useAtom } from "jotai"
import { FC, useEffect, useState } from "react"
import { useLazyPanelLoader } from "./useLazyPanelLoader"

export function useModalLeftTopBar() {
  const [status, setStatus] = useAtom(modalLeftTopBarAtom)
  const { loadPanel } = useLazyPanelLoader()

  const [ActivePanel, setActivePanel] = useState<FC | null>(null)

  useEffect(() => {
    if (status === EPanels.Inactive) {
      setActivePanel(null)
      return
    }

    loadPanel(status).then((panel) => {
      setActivePanel(panel)
    })
  }, [status, loadPanel])

  return { ActivePanel, setStatus }
}
