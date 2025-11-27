"use client"

import { usePathname } from "next/navigation"
import { useEffect } from "react"
import { useSetAtom } from "jotai"
import {
  modalBottomCenterBarAtom,
  modalLeftTopBarAtom,
  modalRightCenterAtom,
  modalTopCenterAtom
} from "@/store/atoms"
import { EPanels } from "@/types/enumeration/EPanels"

export function useResetModalsOnRouteChange() {
  const pathname = usePathname()

  const setRightCenterAtom = useSetAtom(modalRightCenterAtom)
  const setModalLeftTopBarAtom = useSetAtom(modalLeftTopBarAtom)
  const setModalBottomCenterBarAtom = useSetAtom(modalBottomCenterBarAtom)
  const setModalTopCenterAtom = useSetAtom(modalTopCenterAtom)

  useEffect(() => {
    setRightCenterAtom(EPanels.Inactive)
    setModalLeftTopBarAtom(EPanels.Inactive)
    setModalBottomCenterBarAtom(EPanels.Inactive)
    setModalTopCenterAtom(EPanels.Inactive)
  }, [pathname])
}
