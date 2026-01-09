"use client"

import { modalTopCenterAtom } from "@/store/atoms"
import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"
import { componentMapTopCenter } from "@/types/panels/componentMapTopCenter"
import { useAtom } from "jotai"

export function useModalTopCenter() {
  const [modalTopCenter, setModalTopCenter] = useAtom(modalTopCenterAtom)
  const ModalTopCenterPanel = componentMapTopCenter[modalTopCenter]

  function openModalTopCeneter(panel: EPanelsTopCeneter) {
    // setModalTopCenter(EPanelsTopCenter.Inactive) // reset TopCenter
    setModalTopCenter(panel)
  }
  
  function resetModalTopCeneter() {
    setModalTopCenter(EPanelsTopCenter.Inactive)
  }

  return { ModalTopCenterPanel, openModalTopCeneter, resetModalTopCeneter }
}
