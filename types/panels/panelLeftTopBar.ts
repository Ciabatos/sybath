import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import React from "react"

export const panelLeftTopBar: Record<EPanelsLeftTopBar, React.LazyExoticComponent<React.ComponentType<any>> | null> = {
  [EPanelsLeftTopBar.Inactive]: null,
  [EPanelsLeftTopBar.PanelPlayerSquad]: React.lazy(() => import("@/components/panels/PanelPlayerSquad")),
  [EPanelsLeftTopBar.PlayerRibbon]: React.lazy(() => import("@/components/players/PlayerRibbon")),
  [EPanelsLeftTopBar.PlayerPanel]: React.lazy(() => import("@/components/players/PlayerPanel")),
}
