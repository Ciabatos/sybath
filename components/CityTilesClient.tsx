"use client"

import CityTile from "@/components/CityTile"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { TJoinedCityTilesById } from "@/methods/functions/joinCityTiles"
import { useJoinCityTiles } from "@/methods/hooks/cityTIles/useJoinCityTiles"
import { joinedCityTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

interface Props {
  cityId: number
  joinedCityTiles: TJoinedCityTilesById
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export default function CityTilesClient({ cityId, joinedCityTiles, terrainTypes, landscapeTypes }: Props) {
  useJoinCityTiles({ cityId, joinedCityTiles, terrainTypes, landscapeTypes })
  const newJoinedCityTilesOnClient = useAtomValue(joinedCityTilesAtom)
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
