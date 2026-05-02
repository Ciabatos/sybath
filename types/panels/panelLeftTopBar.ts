import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import React from "react"

export const panelLeftTopBar: Record<EPanelsLeftTopBar, React.LazyExoticComponent<React.ComponentType<any>> | null> = {
  [EPanelsLeftTopBar.Inactive]: null,
  [EPanelsLeftTopBar.PlayerRibbonTop]: React.lazy(() => import("@/components/players/PlayerRibbonTop")),
  [EPanelsLeftTopBar.PlayerPanel]: React.lazy(() => import("@/components/players/PlayerPanel")),
  [EPanelsLeftTopBar.PlayerSquad]: React.lazy(() => import("@/components/squad/PlayerSquad")),
}
