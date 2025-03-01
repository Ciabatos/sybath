"use client"
import { useEffect } from "react"
import { useAtom, useAtomValue } from "jotai"
import { joinedMapTilesAtom, mapTilesAtom } from "@/store/atoms"
import { joinMapTilesClient } from "@/methods/functions/joinMapTilesClient"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import { useHydrateAtoms } from "jotai/utils"

export function useJoinMapTiles(joinedMapTiles: Record<string, TjoinedMapTile>, terrainTypesById: Record<number, TMapTerrainTypes>) {
  useHydrateAtoms([[joinedMapTilesAtom, joinedMapTiles]])
  const [atomJoinedMapTiles, setAtomJoinedMapTiles] = useAtom(joinedMapTilesAtom)
  const newMapTiles = useAtomValue(mapTilesAtom)

  useEffect(() => {
    if (newMapTiles) {
      const updatedTiles = joinMapTilesClient(atomJoinedMapTiles, newMapTiles, terrainTypesById)
      setAtomJoinedMapTiles(updatedTiles)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [joinedMapTiles, newMapTiles, terrainTypesById])
}
