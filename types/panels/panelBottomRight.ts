import { EPanelsBottomRight } from "@/types/enumeration/EPanelsBottomRight"
import React from "react"

export const panelBottomRight: Record<EPanelsBottomRight, React.LazyExoticComponent<React.ComponentType<any>> | null> =
  {
    [EPanelsBottomRight.Inactive]: null,
  [EPanelsBottomRight.PlayerRibbonBottom]: React.lazy(() => import("@/components/players/PlayerRibbonBottom")),
  }
