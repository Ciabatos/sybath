"use client"
import ModalBottomCenterBar from "@/components/modals/ModalBottomCenterBar"
import { ModalLeftCenter } from "@/components/modals/ModalLeftCenter"
import ModalLeftTopBar from "@/components/modals/ModalLeftTopBar"
import { ModalRightCenter } from "@/components/modals/ModalRightCenter"
import ModalTopCenter from "@/components/modals/ModalTopCenter"
import ModalTopCenterBar from "@/components/modals/ModalTopCenterBar"
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
      <ModalTopCenterBar />
      <ModalTopCenter />
      <ModalLeftTopBar />
      <ModalRightCenter />
      <ModalLeftCenter />
      <ModalBottomCenterBar />
    </>,
    document.body,
  )
}
