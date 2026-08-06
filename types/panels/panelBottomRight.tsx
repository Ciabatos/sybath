// GENERATED CODE - DO NOT EDIT MANUALLY

import dynamic from "next/dynamic"
import React from "react"
import { EPanelsBottomRight } from "@/types/enumeration/EPanelsBottomRight"

export const panelBottomRight: Record<EPanelsBottomRight, React.ComponentType<any> | null> = {
  [EPanelsBottomRight.Inactive]: null,
  [EPanelsBottomRight.PlayerRibbonBottom]: dynamic(() => import("@/components/players/PlayerRibbonBottom"), {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  })
}
