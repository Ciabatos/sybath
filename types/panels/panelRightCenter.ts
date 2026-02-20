import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import React from "react"

export const panelRightCenter: Record<EPanelsRightCenter, React.LazyExoticComponent<React.ComponentType<any>> | null> =
  {
    [EPanelsRightCenter.Inactive]: null,
    // [EPanelsRightCenter.PanelPlayerPanel]: React.lazy(() => import("@/components/panels/PanelPlayerPanel")),
    [EPanelsRightCenter.PanelMapTileDetail]: React.lazy(() => import("@/components/panels/PanelMapTileDetail")),
    [EPanelsRightCenter.PanelOtherPlayerPanel]: React.lazy(() => import("@/components/panels/PanelOtherPlayerPanel")),
    [EPanelsRightCenter.PanelPlayersOnTile]: React.lazy(() => import("@/components/panels/PanelPlayersOnTile")),
  }
