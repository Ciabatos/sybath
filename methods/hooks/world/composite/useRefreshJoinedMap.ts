"use client"

import { joinMap } from "@/methods/functions/map/joinMap"
import { useFetchCitiesCities } from "@/methods/hooks/cities/core/useFetchCitiesCities"
import { useFetchDistrictsDistricts } from "@/methods/hooks/districts/core/useFetchDistrictsDistricts"
import { useFetchDistrictsDistrictTypes } from "@/methods/hooks/districts/core/useFetchDistrictsDistrictTypes"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchGetPlayerPosition } from "@/methods/hooks/world/core/useFetchGetPlayerPosition"
import { useFetchWorldLandscapeTypes } from "@/methods/hooks/world/core/useFetchWorldLandscapeTypes"
import { useFetchWorldMapTiles } from "@/methods/hooks/world/core/useFetchWorldMapTiles"
import { useFetchWorldTerrainTypes } from "@/methods/hooks/world/core/useFetchWorldTerrainTypes"
import { joinedMapAtom } from "@/store/atoms"
import { useAtom } from "jotai"
import { useEffect } from "react"

export function useRefreshJoinedMap() {
  const { playerId } = usePlayerId()
  const [refreshedJoinedMap, setJoinedMap] = useAtom(joinedMapAtom)
  const { mapTiles } = useFetchWorldMapTiles()
  const { cities } = useFetchCitiesCities()
  const { getPlayerPosition } = useFetchGetPlayerPosition({ mapId: 1, playerId: playerId })
  const { districts } = useFetchDistrictsDistricts()
  const { terrainTypes } = useFetchWorldTerrainTypes()
  const { landscapeTypes } = useFetchWorldLandscapeTypes()
  const { districtTypes } = useFetchDistrictsDistrictTypes()

  useEffect(() => {
    const refreshedData = joinMap({
      tiles: mapTiles,
      terrainTypes: terrainTypes,
      landscapeTypes: landscapeTypes,
      cities: cities,
      districts: districts,
      districtTypes: districtTypes,
      getPlayerPosition: getPlayerPosition,
      options: { oldDataToUpdate: refreshedJoinedMap },
    })
    setJoinedMap(refreshedData)

    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mapTiles, cities, districts, getPlayerPosition])

  return { refreshedJoinedMap }
}
