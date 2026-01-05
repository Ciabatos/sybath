"use client"

import { pathFromPointToPoint, TPathFromPointToPoint } from "@/methods/functions/map/pathFromPointToPoint"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { useFetchCitiesCitiesByKey } from "@/methods/hooks/cities/core/useFetchCitiesCitiesByKey"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useFetchWorldLandscapeTypes } from "@/methods/hooks/world/core/useFetchWorldLandscapeTypes"
import { useFetchWorldMapTilesByKey } from "@/methods/hooks/world/core/useFetchWorldMapTilesByKey"
import { useFetchWorldTerrainTypes } from "@/methods/hooks/world/core/useFetchWorldTerrainTypes"

type TGetPathFromPointToPointParams = {
  startX: number
  startY: number
  endX: number
  endY: number
}

export type TMapTilesMovementPathRecordByXY = Record<string, TPathFromPointToPoint>

export function useMapTilesPathFromPointToPoint() {
  function getPathFromPointToPoint(params: TGetPathFromPointToPointParams) {
    const { mapId } = useMapId()
    const { mapTiles } = useFetchWorldMapTilesByKey({ mapId: mapId })
    const { terrainTypes } = useFetchWorldTerrainTypes()
    const { landscapeTypes } = useFetchWorldLandscapeTypes()
    const { cities } = useFetchCitiesCitiesByKey({ mapId })

    const movementPath = pathFromPointToPoint({
      startX: params.startX,
      startY: params.startY,
      endX: params.endX,
      endY: params.endY,
      mapTiles: mapTiles,
      terrainTypes: terrainTypes,
      landscapeTypes: landscapeTypes,
      cities: cities,
    })

    const movementPathRecordByXY = arrayToObjectKey(["x", "y"], movementPath) as TMapTilesMovementPathRecordByXY
    return movementPathRecordByXY
  }

  return {
    getPathFromPointToPoint,
  }
}
