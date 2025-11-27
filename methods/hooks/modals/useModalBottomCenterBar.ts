// hooks/
import { useAtom } from "jotai"
import { EPanelStatus } from "@/types/enumeration/EPanelStatus"
import { modalBottomCenterBarAtom as modalBottomCenterBarAtom } from "@/store/atoms"
import { usePanelMap } from "./useLazyPanelLoader"
import { FC } from "react"

export function useModalBottomCenterBar() {
  const [status, setStatus] = useAtom(modalBottomCenterBarAtom)
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
