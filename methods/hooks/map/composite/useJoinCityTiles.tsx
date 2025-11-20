"use client"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { joinCity, TJoinCityByXY } from "@/methods/functions/map/joinCity"
import { useFetchBuildings } from "@/methods/hooks/cityTiles/core/useFetchBuildings"
import { useFetchCityTiles } from "@/methods/hooks/cityTiles/core/useFetchCityTiles"
import { joinedCityTilesAtom } from "@/store/atoms"
import { useAtom } from "jotai"
import { useEffect } from "react"

interface Props {
  cityId: number
  joinedCity: TJoinCityByXY
  terrainTypes: TMapTerrainTypesRecordById
  landscapeTypes: TMapLandscapeTypesRecordById
}

export function useRefreshCityHandling({ cityId, joinedCity, terrainTypes, landscapeTypes }: Props) {
  const [refreshedJoinedCity, setJoinedCity] = useAtom(joinedCityAtom)
  const { cityTiles } = useFetchCityTiles(cityId)
  const { buildings } = useFetchBuildings(cityId)


  useEffect(() => {
    if (cityTiles) {
      const refreshedData = joinCity(cityTiles, terrainTypes, landscapeTypes, buildings, { oldDataToUpdate: joinedCity })
      setJoinedCity(refreshedData)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [cityTiles, buildings])

  return { refreshedJoinedCity }
}
