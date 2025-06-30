"use client"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { joinCityTiles, TJoinedCityTilesById } from "@/methods/functions/joinCityTiles"
import { useFetchBuildings } from "@/methods/hooks/cityTiles/core/useFetchBuildings"
import { useFetchCityTiles } from "@/methods/hooks/cityTiles/core/useFetchCityTiles"
import { joinedCityTilesAtom } from "@/store/atoms"
import { useAtom } from "jotai"
import { useEffect } from "react"

interface Props {
  cityId: number
  joinedCityTiles: TJoinedCityTilesById
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export function useJoinCityTiles({ cityId, joinedCityTiles, terrainTypes, landscapeTypes }: Props) {
  const { cityTiles: newCityTiles } = useFetchCityTiles(cityId)
  const { buildings } = useFetchBuildings(cityId)
  const [newJoinedCityTilesOnClient, setJoinedCityTiles] = useAtom(joinedCityTilesAtom)

  useEffect(() => {
    if (newCityTiles) {
      const updatedTiles = joinCityTiles(newCityTiles, terrainTypes, landscapeTypes, buildings, { oldTilesToUpdate: joinedCityTiles })
      setJoinedCityTiles(updatedTiles)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [newCityTiles, buildings])

  return { newJoinedCityTilesOnClient }
}
