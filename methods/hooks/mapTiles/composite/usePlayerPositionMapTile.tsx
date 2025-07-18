"use client"

import { useFetchPlayerVisibleMapData } from "@/methods/hooks/mapTiles/core/useFetchPlayerVisibleMapData"
import { useGetJoinedMapTileByKey } from "@/methods/hooks/mapTiles/core/useGetMapTileByCoordinates"

export function usePlayerPositionMapTile() {
  const { playerPositionMapTile } = useFetchPlayerVisibleMapData()
  const { getTileByCoordinates } = useGetJoinedMapTileByKey()

  const playerMapTile = playerPositionMapTile ? getTileByCoordinates(playerPositionMapTile.map_tile_x, playerPositionMapTile.map_tile_y) : undefined
  //tu zmienic po id trzeba brac z kliknietego obrazka
  return { playerMapTile }
}
