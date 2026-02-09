"use client"

import { TPlayerMovementRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { pathFromPointToPoint } from "@/methods/functions/map/pathFromPointToPoint"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { useFetchCitiesCitiesByKey } from "@/methods/hooks/cities/core/useFetchCitiesCitiesByKey"
import { useFetchDistrictsDistrictsByKey } from "@/methods/hooks/districts/core/useFetchDistrictsDistrictsByKey"
import { useFetchDistrictsDistrictTypes } from "@/methods/hooks/districts/core/useFetchDistrictsDistrictTypes"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useFetchWorldLandscapeTypes } from "@/methods/hooks/world/core/useFetchWorldLandscapeTypes"
import { useFetchWorldMapTilesByKey } from "@/methods/hooks/world/core/useFetchWorldMapTilesByKey"
import { useFetchWorldTerrainTypes } from "@/methods/hooks/world/core/useFetchWorldTerrainTypes"
import {
  citiesAtom,
  districtsAtom,
  districtTypesAtom,
  landscapeTypesAtom,
  mapTilesAtom,
  terrainTypesAtom,
} from "@/store/atoms"
import { useAtomValue } from "jotai"

type TGetPathFromPointToPointParams = {
  startX: number
  startY: number
  endX: number
  endY: number
}

export function useMapTilesPathFromPointToPoint() {
  const { mapId } = useMapId()

  useFetchWorldMapTilesByKey({ mapId })
  const mapTiles = useAtomValue(mapTilesAtom)

  useFetchWorldTerrainTypes()
  const terrainTypes = useAtomValue(terrainTypesAtom)

  useFetchWorldLandscapeTypes()
  const landscapeTypes = useAtomValue(landscapeTypesAtom)

  useFetchCitiesCitiesByKey({ mapId })
  const cities = useAtomValue(citiesAtom)

  useFetchDistrictsDistrictsByKey({ mapId })
  const districts = useAtomValue(districtsAtom)

  useFetchDistrictsDistrictTypes()
  const districtTypes = useAtomValue(districtTypesAtom)

  function getPathFromPointToPoint(params: TGetPathFromPointToPointParams) {
    const movementPath = pathFromPointToPoint({
      startX: params.startX,
      startY: params.startY,
      endX: params.endX,
      endY: params.endY,
      mapTiles: mapTiles,
      terrainTypes: terrainTypes,
      landscapeTypes: landscapeTypes,
      cities: cities,
      districts: districts,
      districtTypes: districtTypes,
    })

    const movementPathRecordByXY = arrayToObjectKey(["x", "y"], movementPath) as TPlayerMovementRecordByXY
    return movementPathRecordByXY
  }

  return {
    getPathFromPointToPoint,
  }
}
