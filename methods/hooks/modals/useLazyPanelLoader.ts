"use client"

import { FC, useCallback } from "react"

export function useLazyPanelLoader() {
  const loadPanel = useCallback(async (panelName: string): Promise<FC | null> => {
    try {
      const mod = await import(`@/components/panels/${panelName}.tsx`)
      return mod.default as FC
    } catch {
      console.warn(`Panel not found: ${panelName}`)
      return null
    }
  }, [])

  return { loadPanel }
}
