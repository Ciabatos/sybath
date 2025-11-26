"use client"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { joinMap, TJoinMapByXY } from "@/methods/functions/map/joinMap"
import { useFetchCitiesCities } from "@/methods/hooks/cities/core/useFetchCitiesCities"
import { useFetchDistrictsDistricts } from "@/methods/hooks/districts/core/useFetchDistrictsDistricts"

import { useFetchPlayerId } from "@/methods/hooks/players/core/useFetchPlayerId"
import { useFetchPlayerVisibleMapData } from "@/methods/hooks/world/core/useFetchPlayerVisibleMapData"
import { useFetchWorldMapTiles } from "@/methods/hooks/world/core/useFetchWorldMapTiles"
import { joinedMapAtom } from "@/store/atoms"
import { useAtom } from "jotai"
import { useEffect } from "react"

interface Props {
  joinedMap: TJoinMapByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
}

export function useRefreshMapHandling({ joinedMap, terrainTypes, landscapeTypes }: Props) {
  const { playerId } = useFetchPlayerId()
  const [refreshedJoinedMap, setJoinedMap] = useAtom(joinedMapAtom)
  const { mapTiles } = useFetchWorldMapTiles()
  const { cities } = useFetchCitiesCities()
  const { playerVisibleMapData } = useFetchPlayerVisibleMapData({ playerId: playerId })
  const { districts } = useFetchDistrictsDistricts()

  useEffect(() => {
    if (mapTiles) {
      const refreshedData = joinMap(mapTiles, terrainTypes, landscapeTypes, cities, districts, playerVisibleMapData, { oldDataToUpdate: joinedMap })
      setJoinedMap(refreshedData)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mapTiles, cities, districts, playerVisibleMapData])

  return { refreshedJoinedMap }
}
