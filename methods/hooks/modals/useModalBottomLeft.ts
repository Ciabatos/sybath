"use client"

import { modalBottomLeftAtom } from "@/store/atoms"
import { EPanelsBottomLeft } from "@/types/enumeration/EPanelsBottomLeft"
import { panelBottomLeft } from "@/types/panels/panelBottomLeft"
import { useAtom } from "jotai"

export function useModalBottomLeft() {
  const [modalBottomLeft, setModalBottomLeft] = useAtom(modalBottomLeftAtom)
  const ModalBottomLeft = panelBottomLeft[modalBottomLeft]

  function openModalBottomLeft(panel: EPanelsBottomLeft) {
    setModalBottomLeft(panel)
  }

  function resetModalBottomLeft() {
    setModalBottomLeft(EPanelsBottomLeft.Inactive)
  }

  return { ModalBottomLeft, openModalBottomLeft, resetModalBottomLeft }
}
