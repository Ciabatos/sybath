import ModalLeftTopHandling from "@/components/portals/modals/modalLeftTop/ModalLeftTopHandling"
import { useEffect, useState } from "react"
import { createPortal } from "react-dom"

export default function LeftTopPortal() {
  const [isMounted, setIsMounted] = useState(false)

  useEffect(() => {
    setIsMounted(true)
  }, [])

  if (!isMounted) {
    return null
  }

  return createPortal(<ModalLeftTopHandling />, document.body)
}
