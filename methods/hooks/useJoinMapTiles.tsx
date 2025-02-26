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
  const [updatedTiles, setUpdatedTiles] = useState(joinedMapTiles)
  const mapTiles = useAtomValue(mapTilesAtom)
  
  useEffect(() => {
    if (mapTiles) {
      const updatedTiles = joinMapTilesClient(joinedMapTiles, mapTiles, terrainTypesById)
      setUpdatedTiles(updatedTiles)
    }
  }, [joinedMapTiles, mapTiles, terrainTypesById])

  return updatedTiles
}
