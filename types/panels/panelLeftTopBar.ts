import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import React from "react"

export const panelLeftTopBar: Record<EPanelsLeftTopBar, React.LazyExoticComponent<React.ComponentType<any>> | null> = {
  [EPanelsLeftTopBar.Inactive]: null,
  [EPanelsLeftTopBar.PanelPlayerPanel]: React.lazy(() => import("@/components/panels/LeftTopBar/PanelPlayerPanel")),
  [EPanelsLeftTopBar.PanelPlayerPortrait]: React.lazy(
    () => import("@/components/panels/LeftTopBar/PanelPlayerPortrait"),
  ),
  [EPanelsLeftTopBar.PanelPlayerSquad]: React.lazy(() => import("@/components/panels/LeftTopBar/PanelPlayerSquad")),
}
