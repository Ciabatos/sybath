"use client"

import { modalTopCenterAtom } from "@/store/atoms"
import { EPanels } from "@/types/enumeration/EPanels"
import { panelComponentMap } from "@/types/panels/leftTopBarComponents"
import { useAtom } from "jotai"

export function useModalTopCenter() {
  const [modalTopCenter, setModalTopCenter] = useAtom(modalTopCenterAtom)
  const ModalTopCenterPanel = panelComponentMap[modalTopCenter]

  function resetModalTopCeneter() {
    setModalTopCenter(EPanels.Inactive)
  }

  return { ModalTopCenterPanel, setModalTopCenter, resetModalTopCeneter }
}
