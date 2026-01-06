import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import React from "react"

export const componentMapLeftTopBar: Record<
  EPanelsLeftTopBar,
  React.LazyExoticComponent<React.ComponentType<any>> | null
> = {
  [EPanelsLeftTopBar.Inactive]: null,
  [EPanelsLeftTopBar.PanelPlayerPanel]: React.lazy(() => import("@/components/panels/PanelPlayerPanel")),
  [EPanelsLeftTopBar.PlayerPortrait]: React.lazy(() => import("@/components/panels/PlayerPortrait")),
}
