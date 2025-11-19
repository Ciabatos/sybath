import { TJoinMap } from "@/methods/functions/map/joinMap"
import { joinedMapAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useGetJoinedMapTileByKey() {
  const joinedMapTiles = useAtomValue(joinedMapAtom)

  function getTileByCoordinates(x: number, y: number): TJoinMap {
    const key = `${x},${y}`
    return joinedMapTiles[key]
  }

  return { getTileByCoordinates }
}
