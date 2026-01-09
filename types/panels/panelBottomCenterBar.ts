import { EPanelsBottomCenterBar } from "@/types/enumeration/EPanelsBottomCenterBar"
import React from "react"

export const panelBottomCenterBar: Record<
  EPanelsBottomCenterBar,
  React.LazyExoticComponent<React.ComponentType<any>> | null
> = {
  [EPanelsBottomCenterBar.Inactive]: null,
}
