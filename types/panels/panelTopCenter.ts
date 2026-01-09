import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"
import React from "react"

export const panelTopCenter: Record<EPanelsTopCenter, React.LazyExoticComponent<React.ComponentType<any>> | null> = {
  [EPanelsTopCenter.Inactive]: null,
  [EPanelsTopCenter.PanelBackToMap]: React.lazy(() => import("@/components/panels/PanelBackToMap")),
}
