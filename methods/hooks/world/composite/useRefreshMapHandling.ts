"use client"

import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { joinMap, TJoinMapByXY } from "@/methods/functions/map/joinMap"
import { useFetchCitiesCities } from "@/methods/hooks/cities/core/useFetchCitiesCities"
import { useFetchDistrictsDistricts } from "@/methods/hooks/districts/core/useFetchDistrictsDistricts"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchPlayerVisibleMapData } from "@/methods/hooks/world/core/useFetchPlayerVisibleMapData"
import { useFetchWorldMapTiles } from "@/methods/hooks/world/core/useFetchWorldMapTiles"
import { joinedMapAtom } from "@/store/atoms"
import { useAtom } from "jotai"
import { useEffect } from "react"

interface Props {
  joinedMap: TJoinMapByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
  districtTypes: TDistrictsDistrictTypesRecordById
}


export function useRefreshMapHandling({ joinedMap, terrainTypes, landscapeTypes, districtTypes }: Props) {
  const { playerId } = usePlayerId()
  const [refreshedJoinedMap, setJoinedMap] = useAtom(joinedMapAtom)
  const { mapTiles } = useFetchWorldMapTiles()
  const { cities } = useFetchCitiesCities()
  const { playerVisibleMapData } = useFetchPlayerVisibleMapData({ playerId: playerId })
  const { districts } = useFetchDistrictsDistricts()

  useEffect(() => {
    if (mapTiles) {
      const refreshedData = joinMap(mapTiles, terrainTypes, landscapeTypes, cities, districts, districtTypes, playerVisibleMapData, { oldDataToUpdate: joinedMap })
      setJoinedMap(refreshedData)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mapTiles, cities, districts, playerVisibleMapData])

  return { refreshedJoinedMap }
}
