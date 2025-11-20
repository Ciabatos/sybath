"use client"

import City from "@/components/city/City"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { TJoinCityByXY } from "@/methods/functions/map/joinCity"
import { useJoinCityTiles } from "@/methods/hooks/map/composite/useJoinCityTiles"

interface Props {
  cityId: number
  joinedCity: TJoinCityByXY
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export default function CityHandling({ cityId, joinedCity, terrainTypes, landscapeTypes }: Props) {
  const { refreshedJoinedCity } = useRefreshCityHandling({ cityId, joinedCity, terrainTypes, landscapeTypes })

  return (
    <>
      {Object.entries(refreshedJoinedCity).map(([key, tile]) => (
        <City
          key={key}
          tile={tile}
        />
      ))}
    </>
  )
}
