import { useFetchGetActivePlayerPosition } from "@/methods/hooks/world/core/useFetchGetActivePlayerPosition"

type Props = {
  mapId: number
  playerId: number
}

export function usePlayerPosition({ mapId, playerId }: Props) {
  const { getPlayerPosition } = useFetchGetActivePlayerPosition({ mapId, playerId })

  return { getPlayerPosition }
}
