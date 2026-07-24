"use client"

import ModalBottomCenter from "@/components/modals/ModalBottomCenter"
import ModalBottomLeft from "@/components/modals/ModalBottomLeft"
import ModalBottomRight from "@/components/modals/ModalBottomRight"
import ModalLeftCenter from "@/components/modals/ModalLeftCenter"
import ModalLeftTopBar from "@/components/modals/ModalLeftTopBar"
import ModalRightCenter from "@/components/modals/ModalRightCenter"
import ModalTopCenter from "@/components/modals/ModalTopCenter"
import ModalTopCenterBar from "@/components/modals/ModalTopCenterBar"
import { useInventoryMonitor } from "@/methods/hooks/inventory/composite/useInventoryMonitor"

export default function ModalHandling() {
  useInventoryMonitor()

  return (
    <>
      <ModalBottomCenter />
      <ModalBottomLeft />
      <ModalBottomRight />
      <ModalLeftCenter />
      <ModalLeftTopBar />
      <ModalRightCenter />
      <ModalTopCenter />
      <ModalTopCenterBar />
    </>
  )
}
