"use client"
import ModalBottomCenterBar from "@/components/modals/ModalBottomCenterBar"
import ModalLeftTopBar from "@/components/modals/ModalLeftTopBar"
import { ModalRightCenter } from "@/components/modals/ModalRightCenter"
import ModalTopCenter from "@/components/modals/ModalTopCenter"
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
      <ModalTopCenter />
      <ModalLeftTopBar />
      <ModalRightCenter />
      <ModalBottomCenterBar />
    </>,
    document.body,
  )
}
