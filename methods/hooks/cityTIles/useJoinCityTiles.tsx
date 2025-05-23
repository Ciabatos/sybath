"use client"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { joinCityTiles, TJoinedCityTilesById } from "@/methods/functions/joinCityTiles"
import { useFetchCityTiles } from "@/methods/hooks/cityTIles/useFetchCityTiles"
import { cityTilesAtom, joinedCityTilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"

interface Props {
  cityId: number
  joinedCityTiles: TJoinedCityTilesById
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export function useJoinCityTiles({ cityId, joinedCityTiles, terrainTypes, landscapeTypes }: Props) {
  useFetchCityTiles(cityId)

  const setJoinedCityTiles = useSetAtom(joinedCityTilesAtom)
  const newCityTiles = useAtomValue(cityTilesAtom)

  useEffect(() => {
    if (newCityTiles) {
      const updatedTiles = joinCityTiles(newCityTiles, terrainTypes, landscapeTypes, { oldTilesToUpdate: joinedCityTiles })
      setJoinedCityTiles(updatedTiles)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [newCityTiles])
}
