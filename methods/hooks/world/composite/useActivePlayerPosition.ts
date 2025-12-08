import { useFetchGetActivePlayerPosition } from "@/methods/hooks/world/core/useFetchGetActivePlayerPosition"

type Props = {
  mapId: number
  playerId: number
}

export function useActivePlayerPosition({ mapId, playerId }: Props) {
  const { getActivePlayerPosition } = useFetchGetActivePlayerPosition({ mapId, playerId })

  return { getActivePlayerPosition }
}
