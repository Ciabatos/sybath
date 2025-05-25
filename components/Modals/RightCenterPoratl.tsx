import { ModalRightCenterHandling } from "@/components/modals/modalRightCenter/ModalRightCenterHandling"
import { useEffect, useState } from "react"
import { createPortal } from "react-dom"

export default function RightCenterPortal() {
  const [isMounted, setIsMounted] = useState(false)

  useEffect(() => {
    setIsMounted(true)
  }, [])

  if (!isMounted) {
    return null
  }

  return createPortal(<ModalRightCenterHandling />, document.body)
}
