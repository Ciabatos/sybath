import { EPanelsLeftCenter } from "@/types/enumeration/EPanelsLeftCenter"
import React from "react"

export const panelLeftCenter: Record<EPanelsLeftCenter, React.LazyExoticComponent<React.ComponentType<any>> | null> = {
  [EPanelsLeftCenter.Inactive]: null,
}
