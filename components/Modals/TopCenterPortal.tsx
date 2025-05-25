import ModalTopCenterHandling from "@/components/modals/modalTopCenter/ModalTopCenterHandling"
import { useEffect, useState } from "react"
import { createPortal } from "react-dom"

export default function TopCenterPortal() {
  const [isMounted, setIsMounted] = useState(false)

  useEffect(() => {
    setIsMounted(true)
  }, [])

  if (!isMounted) {
    return null
  }

  return createPortal(<ModalTopCenterHandling />, document.body)
}
