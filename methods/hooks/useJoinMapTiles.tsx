"use client"
import { TMapLandscapeTypes } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { joinMapTiles } from "@/methods/functions/joinMapTiles"
import { joinedMapTilesAtom, mapTilesAtom, mapTilesPlayerPostionAtom } from "@/store/atoms"
import { useAtom, useAtomValue } from "jotai"
import { useEffect } from "react"

export function useJoinMapTiles(terrainTypes: Record<number, TMapTerrainTypes>, landscapeTypes: Record<number, TMapLandscapeTypes>) {
  const [joinedMapTiles, setJoinedMapTiles] = useAtom(joinedMapTilesAtom)
  const newMapTiles = useAtomValue(mapTilesAtom)
  const mapTilesPlayerPosition = useAtomValue(mapTilesPlayerPostionAtom)

  useEffect(() => {
    if (newMapTiles) {
      const updatedTiles = joinMapTiles(newMapTiles, { terrainTypes, landscapeTypes, mapTilesPlayerPosition, oldTiles: joinedMapTiles })
      setJoinedMapTiles(updatedTiles)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [newMapTiles, mapTilesPlayerPosition])
}
