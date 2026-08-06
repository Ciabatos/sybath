// GENERATED CODE - DO NOT EDIT MANUALLY

import dynamic from "next/dynamic"
import React from "react"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"

export const panelLeftTopBar: Record<EPanelsLeftTopBar, React.ComponentType<any> | null> = {
  [EPanelsLeftTopBar.Inactive]: null,
  [EPanelsLeftTopBar.PlayerPanel]: dynamic(() => import("@/components/players/PlayerPanel"), {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  }),
  [EPanelsLeftTopBar.PlayerRibbonTop]: dynamic(() => import("@/components/players/PlayerRibbonTop"), {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  }),
  [EPanelsLeftTopBar.PlayerSquad]: dynamic(() => import("@/components/squad/PlayerSquad"), {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  })
}
