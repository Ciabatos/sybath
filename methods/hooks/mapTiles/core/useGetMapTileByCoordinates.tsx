import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { joinedMapTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useGetJoinedMapTileByCoordinates() {
  const joinedMapTiles = useAtomValue(joinedMapTilesAtom)

  function getTileByCoordinates(x: number, y: number): TJoinedMapTile {
    const key = `${x},${y}`
    return joinedMapTiles[key]
  }

  return { getTileByCoordinates }
}
