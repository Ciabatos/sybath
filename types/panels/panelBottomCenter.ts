import { EPanelsBottomCenter } from "@/types/enumeration/EPanelsBottomCenter"
import React from "react"

export const panelBottomCenter: Record<
  EPanelsBottomCenter,
  React.LazyExoticComponent<React.ComponentType<any>> | null
> = {
  [EPanelsBottomCenter.Inactive]: null,
  [EPanelsBottomCenter.MovementPanel]: React.lazy(() => import("@/components/map/MovementPanel")),
}
