"use client"
import { useEffect, useState } from "react"
import { useAtomValue } from "jotai"
import { mapTilesAtom } from "@/store/atoms"
import { joinMapTilesClient } from "@/methods/functions/joinMapTilesClient"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"

export function useJoinMapTiles(joinedMapTiles: Record<string, TjoinedMapTile>, terrainTypesById: Record<number, TMapTerrainTypes>) {
  const [tiles, setTiles] = useState(joinedMapTiles)
  const newMapTiles = useAtomValue(mapTilesAtom)

  useEffect(() => {
    if (newMapTiles) {
      const updatedTiles = joinMapTilesClient(tiles, newMapTiles, terrainTypesById)
      setTiles(updatedTiles)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [joinedMapTiles, newMapTiles, terrainTypesById])
  return tiles
}
