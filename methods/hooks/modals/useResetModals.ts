"use client"

import { useModalBottomCenterBar } from "@/methods/hooks/modals/useModalBottomCenterBar"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { EPanels } from "@/types/enumeration/EPanels"

export function useResetModals() {
  const { setModalBottomCenterBarAtom } = useModalBottomCenterBar()
  const { setModalLeftTopBar } = useModalLeftTopBar()
  const { setModalRightCenter } = useModalRightCenter()
  const { setModalTopCenter } = useModalTopCenter()

  function resetModals() {
    setModalBottomCenterBarAtom(EPanels.Inactive)
    setModalLeftTopBar(EPanels.Inactive)
    setModalRightCenter(EPanels.Inactive)
    setModalTopCenter(EPanels.Inactive)
  }

  return { resetModals }
}
