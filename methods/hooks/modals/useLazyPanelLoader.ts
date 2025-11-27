import { FC, useCallback } from "react"

const modules = import.meta.glob('@/components/panels/*.tsx')

export function useLazyPanelLoader() {
  const loadPanel = useCallback(async (panelName: string): Promise<FC | null> => {
    const path = Object.keys(modules).find(p =>
      p.endsWith(`/${panelName}.tsx`)
    )

    if (!path) return null

    const mod = await modules[path]()   // dynamiczny import
    return mod.default as FC
  }, [])

  return { loadPanel }
}
