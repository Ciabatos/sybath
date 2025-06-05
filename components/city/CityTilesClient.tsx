"use client"

import CityTile from "@/components/city/CityTile"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { TJoinedCityTilesById } from "@/methods/functions/joinCityTiles"
import { useJoinCityTiles } from "@/methods/hooks/cityTIles/useJoinCityTiles"

interface Props {
  cityId: number
  joinedCityTiles: TJoinedCityTilesById
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export default function CityTilesClient({ cityId, joinedCityTiles, terrainTypes, landscapeTypes }: Props) {
  const { newJoinedCityTilesOnClient } = useJoinCityTiles({ cityId, joinedCityTiles, terrainTypes, landscapeTypes })

  return (
    <>
      {Object.entries(newJoinedCityTilesOnClient).map(([key, tile]) => (
        <CityTile
          key={key}
          tile={tile}
        />
      ))}
    </>
  )
}
