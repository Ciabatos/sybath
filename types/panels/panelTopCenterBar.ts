import { EPanelsTopCenterBar } from "@/types/enumeration/EPanelsTopCenterBar"
import React from "react"

export const panelTopCenterBar: Record<
  EPanelsTopCenterBar,
  React.LazyExoticComponent<React.ComponentType<any>> | null
> = {
  [EPanelsTopCenterBar.Inactive]: null,
}
