import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import React from "react"

export const componentMapRightCenter: Record<
  EPanelsRightCenter,
  React.LazyExoticComponent<React.ComponentType<any>> | null
> = {
  [EPanelsRightCenter.Inactive]: null,
  [EPanelsRightCenter.PanelPlayerPanel]: React.lazy(() => import("@/components/panels/PanelPlayerPanel")),
}
