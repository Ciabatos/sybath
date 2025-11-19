import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { joinedMapTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useGetJoinedMapTileByKey() {
  const joinedMapTiles = useAtomValue(joinedMapTilesAtom)

  function getTileByCoordinates(key: string): TJoinedMapTile {
    return joinedMapTiles[key]
  }

  return { getTileByCoordinates }
}
