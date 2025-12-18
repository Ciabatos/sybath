"use client"

import { joinMap } from "@/methods/functions/map/joinMap"
import { useFetchCitiesCitiesByKey } from "@/methods/hooks/cities/core/useFetchCitiesCitiesByKey"
import { useFetchDistrictsDistrictsByKey } from "@/methods/hooks/districts/core/useFetchDistrictsDistrictsByKey"
import { useFetchDistrictsDistrictTypes } from "@/methods/hooks/districts/core/useFetchDistrictsDistrictTypes"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useFetchPlayerPosition } from "@/methods/hooks/world/core/useFetchPlayerPosition"
import { useFetchWorldLandscapeTypes } from "@/methods/hooks/world/core/useFetchWorldLandscapeTypes"
import { useFetchWorldMapTilesByKey } from "@/methods/hooks/world/core/useFetchWorldMapTilesByKey"
import { useFetchWorldTerrainTypes } from "@/methods/hooks/world/core/useFetchWorldTerrainTypes"
import { joinedMapAtom } from "@/store/atoms"
import { useAtom } from "jotai"
import { useEffect } from "react"

export function useRefreshJoinedMap() {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()
  const [refreshedJoinedMap, setJoinedMap] = useAtom(joinedMapAtom)
  const { mapTiles } = useFetchWorldMapTilesByKey({ mapId })
  const { cities } = useFetchCitiesCitiesByKey({ mapId })
  const { playerPosition } = useFetchPlayerPosition({ mapId, playerId })
  const { districts } = useFetchDistrictsDistrictsByKey({ mapId })
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
      playerPosition: playerPosition,
      options: { oldDataToUpdate: refreshedJoinedMap },
    })
    setJoinedMap(refreshedData)

    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mapTiles, cities, districts, playerPosition])

  return { refreshedJoinedMap }
}
