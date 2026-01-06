"use client"

import { modalRightCenterAtom } from "@/store/atoms"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { componentMapRightCenter } from "@/types/panels/componentMapRightCenter"
import { useAtom } from "jotai"

export function useModalRightCenter() {
  const [modalRightCenter, setModalRightCenter] = useAtom(modalRightCenterAtom)
  const ModalRightCenter = componentMapRightCenter[modalRightCenter]

  function resetModalRightCenter() {
    setModalRightCenter(EPanelsRightCenter.Inactive)
  }

  return { ModalRightCenter, setModalRightCenter, resetModalRightCenter }
}
