import { TJoinedCityTiles } from "@/methods/functions/joinCityTiles"
import { joinedCityTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useGetJoineCityTileByCoordinates() {
  const joinedCityTiles = useAtomValue(joinedCityTilesAtom)

  function getCityTileByCoordinates(x: number, y: number): TJoinedCityTiles {
    const key = `${x},${y}`
    return joinedCityTiles[key]
  }

  return { getCityTileByCoordinates }
}
