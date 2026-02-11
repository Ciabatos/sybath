"use client"

import ModalBottomCenterBar from "@/components/modals/ModalBottomCenterBar"
import { ModalLeftCenter } from "@/components/modals/ModalLeftCenter"
import ModalLeftTopBar from "@/components/modals/ModalLeftTopBar"
import { ModalRightCenter } from "@/components/modals/ModalRightCenter"
import ModalTopCenter from "@/components/modals/ModalTopCenter"
import ModalTopCenterBar from "@/components/modals/ModalTopCenterBar"
import { useInventoryMonitor } from "@/methods/hooks/inventory/composite/useInventoryMonitor"

export function ModalHandling() {
  useInventoryMonitor()

  return (
    <>
      <ModalTopCenterBar />
      <ModalTopCenter />
      <ModalLeftTopBar />
      <ModalRightCenter />
      <ModalLeftCenter />
      <ModalBottomCenterBar />
    </>
  )
}
