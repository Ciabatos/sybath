// GENERATED CODE - DO NOT EDIT MANUALLY

import dynamic from "next/dynamic"
import React from "react"
import { EPanelsBottomCenter } from "@/types/enumeration/EPanelsBottomCenter"

export const panelBottomCenter: Record<EPanelsBottomCenter, React.ComponentType<any> | null> = {
  [EPanelsBottomCenter.Inactive]: null,
  [EPanelsBottomCenter.MovementPanel]: dynamic(() => import("@/components/map/MovementPanel"), {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  })
}
