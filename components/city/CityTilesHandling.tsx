"use client"

import CityTile from "@/components/city/CityTile"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { TJoinedCityTilesByCoordinates } from "@/methods/functions/map/joinCityTiles"
import { useJoinCityTiles } from "@/methods/hooks/map/composite/useJoinCityTiles"

interface Props {
  cityId: number
  joinedCityTiles: TJoinedCityTilesByCoordinates
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export default function CityTilesHandling({ cityId, joinedCityTiles, terrainTypes, landscapeTypes }: Props) {
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
