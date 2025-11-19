import ModalBottomCenterBarHandling from "@/components/portals/modals/modalBottomCenterBar/ModalBottomCenterBarHandling"
import { useMapTilesActionStatus } from "@/methods/hooks/map/composite/useMapTilesActionStatus"
import { useEffect, useState } from "react"
import { createPortal } from "react-dom"

export default function BottomCenterPortal() {
  const { actualMapTilesActionStatus } = useMapTilesActionStatus()
  const [isMounted, setIsMounted] = useState(false)

  useEffect(() => {
    setIsMounted(true)
  }, [])

  if (!isMounted || actualMapTilesActionStatus.Inactive) {
    return null
  }

  return createPortal(<ModalBottomCenterBarHandling />, document.body)
}
