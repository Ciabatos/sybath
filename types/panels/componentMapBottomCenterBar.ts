import { EPanelsBottomCenterBar } from "@/types/enumeration/EPanelsBottomCenterBar"
import React from "react"

export const componentMapBottomCenterBar: Record<
  EPanelsBottomCenterBar,
  React.LazyExoticComponent<React.ComponentType<any>> | null
> = {
  [EPanelsBottomCenterBar.Inactive]: null,
  [EPanelsBottomCenterBar.PanelPlayerPanel]: React.lazy(() => import("@/components/panels/PanelPlayerPanel")),
}
