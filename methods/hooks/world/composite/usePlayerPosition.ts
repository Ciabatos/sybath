import { useFetchWorldMapTilesPlayersPositionsByKey } from "@/methods/hooks/world/core/useFetchWorldMapTilesPlayersPositionsByKey"
import { playerPositionMapTilesAtom } from "@/store/atoms"
import { useAtom } from "jotai"

export function usePlayerPositionMapTiles() {
  const [playerPositionMapTiles, setPlayerPositionMapTiles] = useAtom(playerPositionMapTilesAtom)
  const { mapTilesPlayersPositions } = useFetchWorldMapTilesPlayersPositionsByKey({ playerId: playerId })

  return { playerPositionMapTiles }
}
