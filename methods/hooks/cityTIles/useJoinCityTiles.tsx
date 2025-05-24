"use client"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { joinCityTiles, TJoinedCityTilesById } from "@/methods/functions/joinCityTiles"
import { useFetchBuildings } from "@/methods/hooks/cityTIles/useFetchBuildings"
import { useFetchCityTiles } from "@/methods/hooks/cityTIles/useFetchCityTiles"
import { buildingsAtom, cityTilesAtom, joinedCityTilesAtom } from "@/store/atoms"
import { useAtom, useAtomValue } from "jotai"
import { useEffect } from "react"

interface Props {
  cityId: number
  joinedCityTiles: TJoinedCityTilesById
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export function useJoinCityTiles({ cityId, joinedCityTiles, terrainTypes, landscapeTypes }: Props) {
  useFetchCityTiles(cityId)
  useFetchBuildings(cityId)

  const [newJoinedCityTilesOnClient, setJoinedCityTiles] = useAtom(joinedCityTilesAtom)
  const newCityTiles = useAtomValue(cityTilesAtom)
  const buildings = useAtomValue(buildingsAtom)

  useEffect(() => {
    if (newCityTiles) {
      const updatedTiles = joinCityTiles(newCityTiles, terrainTypes, landscapeTypes, buildings, { oldTilesToUpdate: joinedCityTiles })
      setJoinedCityTiles(updatedTiles)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [newCityTiles, buildings])

  return { newJoinedCityTilesOnClient }
}
