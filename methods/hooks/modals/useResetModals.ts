"use client"

import { useModalBottomCenterBar } from "@/methods/hooks/modals/useModalBottomCenterBar"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"

export function useResetModals() {
  const { resetModalBottomCenterBar } = useModalBottomCenterBar()
  const { resetModalLeftTopBar } = useModalLeftTopBar()
  const { resetModalRightCenter } = useModalRightCenter()
  const { resetModalTopCeneter } = useModalTopCenter()

  function resetModals() {
    resetModalBottomCenterBar()
    resetModalLeftTopBar()
    resetModalRightCenter()
    resetModalTopCeneter()
  }

  return { resetModals }
}
