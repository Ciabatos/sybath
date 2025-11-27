"use client"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { joinCity, TJoinCityByXY } from "@/methods/functions/city/joinCity"
import { useFetchBuildingsByKey } from "@/methods/hooks/map/core/useFetchBuildingsByKey"
import { useFetchCityTilesByKey } from "@/methods/hooks/map/core/useFetchCityTilesByKey"

import { joinedCityAtom } from "@/store/atoms"
import { useAtom } from "jotai"
import { useEffect } from "react"

interface Props {
  cityId: number
  joinedCity: TJoinCityByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
}

export function useRefreshCityHandling({ cityId, joinedCity, terrainTypes, landscapeTypes }: Props) {
  const [refreshedJoinedCity, setJoinedCity] = useAtom(joinedCityAtom)
  const { cityTiles } = useFetchCityTilesByKey({ cityId })
  const { buildings } = useFetchBuildingsByKey({ id: cityId })

  useEffect(() => {
    if (cityTiles) {
      const refreshedData = joinCity(cityTiles, terrainTypes, landscapeTypes, buildings, { oldDataToUpdate: joinedCity })
      setJoinedCity(refreshedData)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [cityTiles, buildings])

  return { refreshedJoinedCity }
}
