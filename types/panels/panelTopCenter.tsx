// GENERATED CODE - DO NOT EDIT MANUALLY

import dynamic from "next/dynamic"
import React from "react"
import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"

export const panelTopCenter: Record<EPanelsTopCenter, React.ComponentType<any> | null> = {
  [EPanelsTopCenter.Inactive]: null,
  [EPanelsTopCenter.OtherPlayerKnowledgeRequests]: dynamic(() => import("@/components/knowledge/OtherPlayerKnowledgeRequests"), {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  }),
  [EPanelsTopCenter.SquadControls]: dynamic(() => import("@/components/squad/SquadControls"), {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  }),
  [EPanelsTopCenter.TradeList]: dynamic(() => import("@/components/trade/TradeList"), {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  })
}
