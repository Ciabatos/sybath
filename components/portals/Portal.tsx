"use client"
import ModalBottomCenterBar from "@/components/modals/ModalBottomCenterBar"
import { useResetModalsOnRouteChange } from "@/methods/hooks/modals/useResetModalsOnRouteChange"
import { useEffect, useState } from "react"
import { createPortal } from "react-dom"
import ModalLeftTopBar from "../modals/ModalLeftTopBar"
import { ModalRightCenter } from "../modals/ModalRightCenter"
import ModalTopCenter from "../modals/ModalTopCenter"

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
