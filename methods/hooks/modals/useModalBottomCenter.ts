"use client"

import { modalBottomCenterAtom } from "@/store/atoms"
import { EPanelsBottomCenter } from "@/types/enumeration/EPanelsBottomCenter"
import { panelBottomCenter } from "@/types/panels/panelBottomCenter"
import { useAtom } from "jotai"

export function useModalBottomCenter() {
  const [modalBottomCenter, setModalBottomCenter] = useAtom(modalBottomCenterAtom)
  const ModalBottomCenter = panelBottomCenter[modalBottomCenter]

  function openModalBottomCenter(panel: EPanelsBottomCenter) {
    setModalBottomCenter(panel)
  }

  function resetModalBottomCenter() {
    setModalBottomCenter(EPanelsBottomCenter.Inactive)
  }

  return { ModalBottomCenter, openModalBottomCenter, resetModalBottomCenter }
}
