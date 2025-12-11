"use client"

import City from "@/components/city/City"
import { TBuildingsBuildingTypesRecordById } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { TJoinCityByXY } from "@/methods/functions/city/joinCity"
import { useRefreshCityHandling } from "@/methods/hooks/cities/composite/useRefreshCityHandling"

interface Props {
  cityId: number
  joinedCity: TJoinCityByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
  buildingsTypes: TBuildingsBuildingTypesRecordById
}

export default function CityHandling({ cityId, joinedCity, terrainTypes, landscapeTypes, buildingsTypes }: Props) {
  const { refreshedJoinedCity } = useRefreshCityHandling({
    cityId,
    joinedCity,
    terrainTypes,
    landscapeTypes,
    buildingsTypes,
  })

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
