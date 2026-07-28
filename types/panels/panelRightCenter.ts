// GENERATED CODE - DO NOT EDIT MANUALLY
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import React from "react"

export const panelRightCenter: Record<
  EPanelsRightCenter,
  React.LazyExoticComponent<React.ComponentType<any>> | null
> = {
  [EPanelsRightCenter.Inactive]: null,
  [EPanelsRightCenter.AllAbilities]: React.lazy(() => import("@/components/attributes/AllAbilities")),
  [EPanelsRightCenter.AllSkills]: React.lazy(() => import("@/components/attributes/AllSkills")),
  [EPanelsRightCenter.Crafting]: React.lazy(() => import("@/components/items/Crafting")),
  [EPanelsRightCenter.MapTileDetail]: React.lazy(() => import("@/components/map/MapTileDetail")),
  [EPanelsRightCenter.OtherPlayerPanel]: React.lazy(() => import("@/components/players/OtherPlayerPanel"))
}
