import { EPanelsBottomLeft } from "@/types/enumeration/EPanelsBottomLeft"
import React from "react"

export const panelBottomLeft: Record<EPanelsBottomLeft, React.LazyExoticComponent<React.ComponentType<any>> | null> = {
  [EPanelsBottomLeft.Inactive]: null,
  [EPanelsBottomLeft.PlayersOnTile]: React.lazy(() => import("@/components/players/PlayersOnTile")),
}
