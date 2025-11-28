import { FC, useCallback } from "react"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const modules = (require as any).context(
  '@/components/panels',
  false,
  /\.tsx$/
)


export function useLazyPanelLoader() {
  const loadPanel = useCallback(async (panelName: string): Promise<FC | null> => {
    const key = `./${panelName}.tsx`

    if (!modules.keys().includes(key)) {
      return null
    }

    const mod = await modules(key)
    return mod.default as FC
  }, [])

  return { loadPanel }
}