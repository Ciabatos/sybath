"use client"

import { modalBottomRightAtom } from "@/store/atoms"
import { EPanelsBottomRight } from "@/types/enumeration/EPanelsBottomRight"
import { panelBottomRight } from "@/types/panels/panelBottomRight"
import { useAtom } from "jotai"

export function useModalBottomRight() {
  const [modalBottomRight, setModalBottomRight] = useAtom(modalBottomRightAtom)
  const ModalBottomRight = panelBottomRight[modalBottomRight]

  function openModalBottomRight(panel: EPanelsBottomRight) {
    setModalBottomRight(panel)
  }

  function resetModalBottomRight() {
    setModalBottomRight(EPanelsBottomRight.Inactive)
  }

  return { ModalBottomRight, openModalBottomRight, resetModalBottomRight }
}
