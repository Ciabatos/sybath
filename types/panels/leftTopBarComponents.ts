import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import React from "react"

export const panelComponentMap: Record<EPanelsLeftTopBar, React.LazyExoticComponent<React.ComponentType<any>> | null> =
  {
    [EPanelsLeftTopBar.Inactive]: null,
    // lazy load tylko potrzebnych komponentów:
    [EPanelsLeftTopBar.PanelPlayerPanel]: React.lazy(() => import("@/components/panels/PanelPlayerPanel")),
    // [EPanelsLeftTopBar.PanelPlayerInventory]: React.lazy(() => import("@/components/panels/PanelPlayerInventory")),
    // [EPanelsLeftTopBar.PanelPlayerSkills]: React.lazy(() => import("@/components/panels/PanelPlayerSkills")),
    // [EPanelsLeftTopBar.PanelPlayerAbilities]: React.lazy(() => import("@/components/panels/PanelPlayerAbilities")),
    // [EPanelsLeftTopBar.PanelPartyInventory]: React.lazy(() => import("@/components/panels/PanelPartyInventory")),
  }
