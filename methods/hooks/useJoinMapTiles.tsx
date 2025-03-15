"use client"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { joinMapTilesClient } from "@/methods/functions/joinMapTilesClient"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import { joinedMapTilesAtom, mapTilesAtom, mapTilesPlayerPostionAtom } from "@/store/atoms"
import { useAtom, useAtomValue } from "jotai"
import { useHydrateAtoms } from "jotai/utils"
import { useEffect } from "react"

export function useJoinMapTiles(joinedMapTiles: Record<string, TjoinedMapTile>, terrainTypesById: Record<number, TMapTerrainTypes>) {
  useHydrateAtoms([[joinedMapTilesAtom, joinedMapTiles]])
  const [atomJoinedMapTiles, setAtomJoinedMapTiles] = useAtom(joinedMapTilesAtom)
  const newMapTiles = useAtomValue(mapTilesAtom)
  const mapTilesPlayerPostion = useAtomValue(mapTilesPlayerPostionAtom)

  useEffect(() => {
    if (newMapTiles) {
      const updatedTiles = joinMapTilesClient(atomJoinedMapTiles, newMapTiles, terrainTypesById, mapTilesPlayerPostion)
      setAtomJoinedMapTiles(updatedTiles)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [joinedMapTiles, newMapTiles, terrainTypesById, mapTilesPlayerPostion])
}
