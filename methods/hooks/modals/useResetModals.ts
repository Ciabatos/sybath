"use client"

import { useModalBottomCenterBar } from "@/methods/hooks/modals/useModalBottomCenterBar"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { EPanelsBottomCenterBar } from "@/types/enumeration/EPanelsBottomCenterBar"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"

export function useResetModals() {
  const { setModalBottomCenterBar } = useModalBottomCenterBar()
  const { setModalLeftTopBar } = useModalLeftTopBar()
  const { setModalRightCenter } = useModalRightCenter()
  const { setModalTopCenter } = useModalTopCenter()

  function resetModals() {
    setModalBottomCenterBar(EPanelsBottomCenterBar.Inactive)
    setModalLeftTopBar(EPanelsLeftTopBar.Inactive)
    setModalRightCenter(EPanelsRightCenter.Inactive)
    setModalTopCenter(EPanelsTopCenter.Inactive)
  }

  return { resetModals }
}
