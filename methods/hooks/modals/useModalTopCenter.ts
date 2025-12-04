import { useAtom } from "jotai"
import { EPanels } from "@/types/enumeration/EPanels"
import { modalTopCenterAtom as modalTopCenterAtom } from "@/store/atoms"
import { useLazyPanelLoader } from "./useLazyPanelLoader"
import { FC, useEffect, useState } from "react"

export function useModalTopCenter() {
  const [status, setStatus] = useAtom(modalTopCenterAtom)
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
