import { useFetchPlayerVisibleMapData } from "@/methods/hooks/mapTiles/core/useFetchPlayerVisibleMapData"
import { useGetJoinedMapTileByCoordinates } from "@/methods/hooks/mapTiles/core/useGetMapTileByCoordinates"

export function usePlayerPositionMapTile() {
  const { playerPositionMapTile } = useFetchPlayerVisibleMapData()
  const { getTileByCoordinates } = useGetJoinedMapTileByCoordinates()

  const playerMapTile = playerPositionMapTile ? getTileByCoordinates(playerPositionMapTile.map_tile_x, playerPositionMapTile.map_tile_y) : undefined

  return { playerMapTile }
}
