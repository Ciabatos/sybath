"use client"

import { modalTopCenterAtom } from "@/store/atoms"
import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"
import { panelTopCenter } from "@/types/panels/panelTopCenter"
import { useAtom } from "jotai"

export function useModalTopCenter() {
  const [modalTopCenter, setModalTopCenter] = useAtom(modalTopCenterAtom)
  const ModalTopCenter = panelTopCenter[modalTopCenter]

  function openModalTopCenter(panel: EPanelsTopCenter) {
    setModalTopCenter(panel)
  }

  function resetModalTopCeneter() {
    setModalTopCenter(EPanelsTopCenter.Inactive)
  }

  return { ModalTopCenter, openModalTopCenter, resetModalTopCeneter }
}
