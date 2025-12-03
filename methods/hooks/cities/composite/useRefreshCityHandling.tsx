"use client"

import { TBuildingsBuildingTypesRecordById } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { TJoinCityByXY, joinCity } from "@/methods/functions/city/joinCity"
import { useFetchBuildingsBuildingsByKey } from "@/methods/hooks/buildings/core/useFetchBuildingsBuildingsByKey"
import { useFetchCitiesCityTilesByKey } from "@/methods/hooks/cities/core/useFetchCitiesCityTilesByKey"
import { joinedCityAtom } from "@/store/atoms"
import { useAtom } from "jotai"
import { useEffect } from "react"

interface Props {
  cityId: number
  joinedCity: TJoinCityByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
  buildingsTypes: TBuildingsBuildingTypesRecordById
}

export function useRefreshCityHandling({ cityId, joinedCity, terrainTypes, landscapeTypes, buildingsTypes }: Props) {
  const [refreshedJoinedCity, setJoinedCity] = useAtom(joinedCityAtom)
  const { cityTiles } = useFetchCitiesCityTilesByKey({ cityId })
  const { buildings } = useFetchBuildingsBuildingsByKey({ id: cityId })

  useEffect(() => {
    if (cityTiles) {
      const refreshedData = joinCity(cityTiles, terrainTypes, landscapeTypes, buildings, buildingsTypes, { oldDataToUpdate: joinedCity })
      setJoinedCity(refreshedData)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [cityTiles, buildings])

  return { refreshedJoinedCity }
}
