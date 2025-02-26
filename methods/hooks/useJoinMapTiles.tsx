"use client"
import { useEffect, useState } from "react"
import { joinMapTilesClient } from "@/methods/functions/joinMapTilesClient"
import { mapTilesAtom } from "@/store/atoms"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesClient"
import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"

export function useJoinMapTiles(
  joinedMapTiles: Record<string, TjoinedMapTile>,
  terrainTypesById: Record<number, TMapTerrainTypes>
) {
  const [tiles, setTiles] = useState(joinedMapTiles)
  const newMapTiles = useAtomValue(mapTilesAtom)
  
  
  useEffect(() => {
    if (newMapTiles) {
      const updatedTiles = joinMapTilesClient( tiles, newMapTiles, terrainTypesById)
      setTiles(updatedTiles)
    }
  }, [joinedMapTiles, newMapTiles, terrainTypesById])

  return tiles
}
