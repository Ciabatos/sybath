// GENERATED CODE - DO NOT EDIT MANUALLY
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import React from "react"

export const panelLeftTopBar: Record<
  EPanelsLeftTopBar,
  React.LazyExoticComponent<React.ComponentType<any>> | null
> = {
  [EPanelsLeftTopBar.Inactive]: null,
  [EPanelsLeftTopBar.PlayerPanel]: React.lazy(() => import("@/components/players/PlayerPanel")),
  [EPanelsLeftTopBar.PlayerRibbonTop]: React.lazy(() => import("@/components/players/PlayerRibbonTop")),
  [EPanelsLeftTopBar.PlayerSquad]: React.lazy(() => import("@/components/squad/PlayerSquad"))
}
