"use client"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { joinCityTiles } from "@/methods/functions/joinCityTiles"
import { useFetchCityTiles } from "@/methods/hooks/cityTIles/useFetchCityTiles"
import { cityTilesAtom, joinedCityTilesAtom } from "@/store/atoms"
import { useAtom, useAtomValue } from "jotai"
import { useEffect } from "react"

export function useJoinCityTiles(cityId: number, terrainTypes: TMapTerrainTypesById, landscapeTypes: TMapLandscapeTypesById) {
  useFetchCityTiles(cityId)

  const [joinedCityTiles, setJoinedCityTiles] = useAtom(joinedCityTilesAtom)
  const newCityTiles = useAtomValue(cityTilesAtom)

  useEffect(() => {
    if (newCityTiles) {
      const updatedTiles = joinCityTiles(newCityTiles, terrainTypes, landscapeTypes, { oldTilesToUpdate: joinedCityTiles })
      setJoinedCityTiles(updatedTiles)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [newCityTiles])
}
