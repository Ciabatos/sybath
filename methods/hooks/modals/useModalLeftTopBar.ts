import { useAtom } from "jotai"
import { EPanelStatus } from "@/types/enumeration/EPanelStatus"
import { modalLeftTopBarAtom as modalLeftTopBarAtom } from "@/store/atoms"
import { usePanelMap } from "./useLazyPanelLoader"
import { FC } from "react"

export function useModalLeftTopBar() {
  const [status, setStatus] = useAtom(modalLeftTopBarAtom)
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
