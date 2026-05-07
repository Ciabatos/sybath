"use client"

import { useModalBottomCenter } from "@/methods/hooks/modals/useModalBottomCenter"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"

export function useResetModals() {
  const { resetModalBottomCenter } = useModalBottomCenter()
  const { resetModalLeftTopBar } = useModalLeftTopBar()
  const { resetModalRightCenter } = useModalRightCenter()
  const { resetModalTopCenter } = useModalTopCenter()

  function resetModals() {
    resetModalBottomCenter()
    resetModalLeftTopBar()
    resetModalRightCenter()
    resetModalTopCenter()
  }

  return { resetModals }
}
