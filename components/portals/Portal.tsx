import ModalBottomCenterBarHandling from "@/components/modals/ModalBottomCenterBar"
import { useMapTilesActionStatus } from "@/methods/hooks/world/composite/useMapTilesActionStatus"
import { useEffect, useState } from "react"
import { createPortal } from "react-dom"

export default function Portal() {
  const [isMounted, setIsMounted] = useState(false)

  useEffect(() => {
    setIsMounted(true)
  }, [])

  if (!isMounted) {
    return null
  }

  return createPortal(
    <>
      <ModalTopCenterHandling />
      <ModalLeftTopHandling /> 
      <ModalRightCenterHandling />
      <ModalBottomCenterBarHandling />
    </>,
    document.body)
}
