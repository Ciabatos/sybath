"use client"
import { useResetModalsOnRouteChange } from "@/methods/hooks/modals/useResetModalsOnRouteChange"
import { useEffect, useState } from "react"
import { createPortal } from "react-dom"
import ModalTopCenter from "../modals/ModalTopCenter"
import ModalLeftTopBar from "../modals/ModalLeftTopBar"
import { ModalRightCenter } from "../modals/ModalRightCenter"
import ModalBottomCenterBar from "@/components/modals/ModalBottomCenterBar"

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
    document.body)
}
