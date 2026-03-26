"use client"

import { pathFromPointToPoint, TPlayerMovementRecordByXY } from "@/methods/functions/map/pathFromPointToPoint"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { useCitiesCitiesState, useFetchCitiesCitiesByKey } from "@/methods/hooks/cities/core/useFetchCitiesCitiesByKey"
import {
  useDistrictsDistrictsState,
  useFetchDistrictsDistrictsByKey,
} from "@/methods/hooks/districts/core/useFetchDistrictsDistrictsByKey"
import {
  useDistrictsDistrictTypesState,
  useFetchDistrictsDistrictTypes,
} from "@/methods/hooks/districts/core/useFetchDistrictsDistrictTypes"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useFetchKnownMapTiles, useKnownMapTilesState } from "@/methods/hooks/world/core/useFetchKnownMapTiles"
import {
  useFetchWorldLandscapeTypes,
  useWorldLandscapeTypesState,
} from "@/methods/hooks/world/core/useFetchWorldLandscapeTypes"
import {
  useFetchWorldTerrainTypes,
  useWorldTerrainTypesState,
} from "@/methods/hooks/world/core/useFetchWorldTerrainTypes"

type TGetPathFromPointToPointParams = {
  startX: number
  startY: number
  endX: number
  endY: number
}

export function useMapTilesPathFromPointToPoint() {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()

  useFetchKnownMapTiles({ mapId, playerId })
  const knownMapTiles = useKnownMapTilesState()

  useFetchWorldTerrainTypes()
  const terrainTypes = useWorldTerrainTypesState()

  useFetchWorldLandscapeTypes()
  const landscapeTypes = useWorldLandscapeTypesState()

  useFetchCitiesCitiesByKey({ mapId })
  const cities = useCitiesCitiesState()

  useFetchDistrictsDistrictsByKey({ mapId })
  const districts = useDistrictsDistrictsState()

  useFetchDistrictsDistrictTypes()
  const districtTypes = useDistrictsDistrictTypesState()

  function getPathFromPointToPoint(params: TGetPathFromPointToPointParams) {
    const movementPath = pathFromPointToPoint({
      startX: params.startX,
      startY: params.startY,
      endX: params.endX,
      endY: params.endY,
      mapTiles: knownMapTiles,
      terrainTypes: terrainTypes,
      landscapeTypes: landscapeTypes,
      cities: cities,
      districts: districts,
      districtTypes: districtTypes,
    })
    if (!movementPath) {
      return null
    }
    const movementPathRecordByXY = arrayToObjectKey(["x", "y"], movementPath) as TPlayerMovementRecordByXY
    return movementPathRecordByXY
  }

  return {
    getPathFromPointToPoint,
  }
}
