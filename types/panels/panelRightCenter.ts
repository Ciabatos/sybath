import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import React from "react"

export const panelRightCenter: Record<EPanelsRightCenter, React.LazyExoticComponent<React.ComponentType<any>> | null> =
  {
    [EPanelsRightCenter.Inactive]: null,
    [EPanelsRightCenter.AllSkills]: React.lazy(() => import("@/components/attributes/AllSkills")),
    [EPanelsRightCenter.MapTileDetail]: React.lazy(() => import("@/components/map/MapTileDetail")),
    [EPanelsRightCenter.OtherPlayerPanel]: React.lazy(() => import("@/components/players/OtherPlayerPanel")),
  }
