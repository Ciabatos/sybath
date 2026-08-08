// GENERATED CODE - DO NOT EDIT MANUALLY

import dynamic from "next/dynamic"
import React from "react"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"

export const panelRightCenter: Record<EPanelsRightCenter, React.ComponentType<any> | null> = {
  [EPanelsRightCenter.Inactive]: null,
  [EPanelsRightCenter.AllAbilities]: dynamic(() => import("@/components/attributes/AllAbilities"), {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  }),
  [EPanelsRightCenter.AllSkills]: dynamic(() => import("@/components/attributes/AllSkills"), {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  }),
  [EPanelsRightCenter.Crafting]: dynamic(() => import("@/components/items/Crafting"), {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  }),
  [EPanelsRightCenter.MapTileDetail]: dynamic(() => import("@/components/map/MapTileDetail"), {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  }),
  [EPanelsRightCenter.OtherPlayerPanel]: dynamic(() => import("@/components/players/OtherPlayerPanel"), {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  }),
  [EPanelsRightCenter.Trade]: dynamic(() => import("@/components/trade/Trade"), {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  })
}
