"use client"
import { ModalHandling } from "@/components/modals/ModalHandling"
import { useResetModalsOnRouteChange } from "@/methods/hooks/modals/useResetModalsOnRouteChange"
import { useEffect, useState } from "react"
import { createPortal } from "react-dom"

export default function Portal() {
  const [isMounted, setIsMounted] = useState(false)
  useResetModalsOnRouteChange()

  useEffect(() => {
    setIsMounted(true)
  }, [])

  if (!isMounted) {
    return null
  }

  return createPortal(
    <>
      <ModalHandling />
    </>,
    document.body,
  )
}
