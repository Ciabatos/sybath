// GENERATED CODE - DO NOT EDIT MANUALLY
import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"
import React from "react"

export const panelTopCenter: Record<
  EPanelsTopCenter,
  React.LazyExoticComponent<React.ComponentType<any>> | null
> = {
  [EPanelsTopCenter.Inactive]: null,
  [EPanelsTopCenter.OtherPlayerKnowledgeRequests]: React.lazy(() => import("@/components/knowledge/OtherPlayerKnowledgeRequests")),
  [EPanelsTopCenter.SquadControls]: React.lazy(() => import("@/components/squad/SquadControls"))
}
