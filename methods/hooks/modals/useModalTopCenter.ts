"use client"

import { modalTopCenterAtom } from "@/store/atoms"
import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"
import { panelComponentMap } from "@/types/panels/leftTopBarComponents"
import { useAtom } from "jotai"

export function useModalTopCenter() {
  const [modalTopCenter, setModalTopCenter] = useAtom(modalTopCenterAtom)
  const ModalTopCenterPanel = panelComponentMap[modalTopCenter]

  function resetModalTopCeneter() {
    setModalTopCenter(EPanelsTopCenter.Inactive)
  }

  return { ModalTopCenterPanel, setModalTopCenter, resetModalTopCeneter }
}
