// hooks/useModalRightCenter.ts
import { useAtom } from "jotai"
import { modalRightCenterAtom } from "@/store/atoms"
import { useEffect, useState } from "react"
import { FC } from "react"
import { EPanels } from "@/types/enumeration/EPanels"
import { useLazyPanelLoader } from "./useLazyPanelLoader"

export function useModalRightCenter() {
  const [status, setStatus] = useAtom(modalRightCenterAtom)
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
