// GENERATED CODE - DO NOT EDIT MANUALLY

import dynamic from "next/dynamic"
import React from "react"
import { EPanelsBottomLeft } from "@/types/enumeration/EPanelsBottomLeft"

export const panelBottomLeft: Record<EPanelsBottomLeft, React.ComponentType<any> | null> = {
  [EPanelsBottomLeft.Inactive]: null,
  [EPanelsBottomLeft.PlayersOnTile]: dynamic(() => import("@/components/players/PlayersOnTile"), {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  })
}
