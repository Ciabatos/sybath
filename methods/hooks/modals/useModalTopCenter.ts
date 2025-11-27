import { useAtom } from "jotai"
import { EPanelStatus } from "@/types/enumeration/EPanelStatus"
import { modalTopCenterAtom as modalTopCenterAtom } from "@/store/atoms"
import { usePanelMap } from "./useLazyPanelLoader"
import { FC } from "react"

export function useModalTopCenter() {
  const [status, setStatus] = useAtom(modalTopCenterAtom)
  const { loadPanel } = useLazyPanelLoader()

  const [ActivePanel, setActivePanel] = useState<FC | null>(null)

  useEffect(() => {
    if (status === EPanelStatus.Inactive) {
      setActivePanel(null)
      return
    }

    loadPanel(status).then(panel => {
      setActivePanel(panel)
    })
  }, [status, loadPanel])

  return { ActivePanel, setStatus }
}
