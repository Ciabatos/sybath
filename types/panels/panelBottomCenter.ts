import { EPanelsBottomCenter } from "@/types/enumeration/EPanelsBottomCenter"
import React from "react"

export const panelBottomCenterBar: Record<
  EPanelsBottomCenter,
  React.LazyExoticComponent<React.ComponentType<any>> | null
> = {
  [EPanelsBottomCenter.Inactive]: null,
}
