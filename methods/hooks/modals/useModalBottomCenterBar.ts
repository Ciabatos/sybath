// hooks/
import { useAtom } from "jotai"
import { EPanels } from "@/types/enumeration/EPanels"
import { modalBottomCenterBarAtom as modalBottomCenterBarAtom } from "@/store/atoms"
import { useLazyPanelLoader } from "./useLazyPanelLoader"
import { FC, useEffect, useState } from "react"

export function useModalBottomCenterBar() {
  const [status, setStatus] = useAtom(modalBottomCenterBarAtom)
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
