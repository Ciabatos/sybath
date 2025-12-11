import { useFetchGetPlayerPosition } from "@/methods/hooks/world/core/useFetchGetPlayerPosition"

type Props = {
  mapId: number
  playerId: number
}

export function usePlayerPosition({ mapId, playerId }: Props) {
  const { getPlayerPosition } = useFetchGetPlayerPosition({ mapId, playerId })

  return { getPlayerPosition }
}
