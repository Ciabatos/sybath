"use client"
import { TMapLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { joinMap, TJoinMapByXY } from "@/methods/functions/map/joinMap"
import { useFetchCities } from "@/methods/hooks/map/core/useFetchCities"
import { useFetchDistricts } from "@/methods/hooks/map/core/useFetchDistricts"
import { useFetchMapTiles } from "@/methods/hooks/map/core/useFetchMapTiles"
import { useFetchPlayerVisibleMapData } from "@/methods/hooks/map/core/useFetchPlayerVisibleMapData"
import { useFetchPlayerId } from "@/methods/hooks/players/core/useFetchPlayerId"
import { joinedMapAtom } from "@/store/atoms"
import { useAtom } from "jotai"
import { useEffect } from "react"

interface Props {
  joinedMap: TJoinMapByXY
  terrainTypes: TMapTerrainTypesRecordById
  landscapeTypes: TMapLandscapeTypesRecordById
}

export function useRefreshMapHandling({ joinedMap, terrainTypes, landscapeTypes }: Props) {
  const { playerId } = useFetchPlayerId()
  const [refreshedJoinedMap, setJoinedMap] = useAtom(joinedMapAtom)
  const { mapTiles } = useFetchMapTiles()
  const { cities } = useFetchCities()
  const { playerVisibleMapData } = useFetchPlayerVisibleMapData({ playerId: playerId })
  const { districts } = useFetchDistricts()

  useEffect(() => {
    if (mapTiles) {
      const refreshedData = joinMap(mapTiles, terrainTypes, landscapeTypes, cities, districts, playerVisibleMapData, { oldDataToUpdate: joinedMap })
      setJoinedMap(refreshedData)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mapTiles, cities, districts, playerVisibleMapData])

  return { refreshedJoinedMap }
}
